def parse_json(s):
    return parse_element(s)

def parse_value(s):
    return alternate(
        parse_object,
        parse_array,
        parse_string,
        parse_number,
        parse_true,
        parse_false,
        parse_null,
    )(s)

def parse_object(s):
    return alternate(
        sequence(
            parse_char("{"),
            parse_whitespace,
            parse_char("}"),
        ),
        sequence(
            parse_char("{"),
            parse_members,
            parse_char("}"),
        ),
    )(s)

def parse_members(s):
    return alternate(
        parse_member,
        sequence(
            parse_member,
            parse_char(","),
            parse_members,
        ),
    )(s)

def parse_member(s):
    return sequence(
        parse_whitespace,
        parse_string,
        parse_whitespace,
        parse_char(":"),
        parse_element,
    )(s)

def parse_array(s):
    return alternate(
        sequence(
            parse_char("["),
            parse_whitespace,
            parse_char("]"),
        ),
        sequence(
            parse_char("["),
            parse_elements,
            parse_char("]"),
        ),
    )(s)

def parse_elements(s):
    return alternate(
        parse_element,
        sequence(
            parse_element,
            parse_char(","),
            parse_elements,
        ),
    )(s)

def parse_element(s):
    return sequence(
        parse_whitespace,
        parse_value,
        parse_whitespace,
    )(s)

def parse_string(s):
    return sequence(
        parse_char('"'),
        parse_characters,
        parse_char('"'),
    )(s)

def parse_characters(s):
    return alternate(
        parse_empty,
        sequence(
            parse_character,
            parse_characters,
        ),
    )(s)

def parse_character(s):
    return alternate(
        parse_almost_any_char,
        sequence(
            parse_char("\\"),
            parse_escape,
        ),
    )(s)

def parse_escape(s):
    return alternate(
        parse_char('"'),
        parse_char("\\"),
        parse_char("b"),
        parse_char("f"),
        parse_char("n"),
        parse_char("r"),
        parse_char("t"),
        sequence(
            parse_char("u"),
            parse_hex,
            parse_hex,
            parse_hex,
            parse_hex,
        ),
    )(s)

def parse_hex(s):
    return alternate(
        parse_digit,
        alternate(
            parse_char("A"),
            parse_char("B"),
            parse_char("C"),
            parse_char("D"),
            parse_char("E"),
            parse_char("F"),
        ),
        alternate(
            parse_char("a"),
            parse_char("b"),
            parse_char("c"),
            parse_char("d"),
            parse_char("e"),
            parse_char("f"),
        ),
    )(s)

def parse_number(s):
    return sequence(
        parse_integer,
        parse_fraction,
        parse_exponent,
    )(s)

def parse_integer(s):
    return alternate(
        parse_digit,
        sequence(
            parse_onenine,
            parse_digits,
        ),
        sequence(
            parse_char("-"),
            parse_digit,
        ),
        sequence(
            parse_char("-"),
            parse_onenine,
            parse_digits,
        ),
    )(s)

def parse_digits(s):
    return alternate(
        parse_digit,
        sequence(
            parse_digit,
            parse_digits,
        ),
    )(s)

def parse_digit(s):
    return alternate(
        parse_char("0"),
        parse_onenine,
    )(s)

def parse_onenine(s):
    return alternate(
        parse_char("1"),
        parse_char("2"),
        parse_char("3"),
        parse_char("4"),
        parse_char("5"),
        parse_char("6"),
        parse_char("7"),
        parse_char("8"),
        parse_char("9"),
    )(s)

def parse_fraction(s):
    return alternate(
        parse_empty,
        sequence(
            parse_char("."),
            parse_digits,
        ),
    )(s)

def parse_exponent(s):
    return alternate(
        parse_empty,
        sequence(
            parse_char("E"),
            parse_sign,
            parse_digits,
        ),
        sequence(
            parse_char("e"),
            parse_sign,
            parse_digits,
        ),
    )(s)

def parse_sign(s):
    return alternate(
        parse_empty,
        parse_char("+"),
        parse_char("-"),
    )(s)

def parse_whitespace(s):
    return alternate(
        parse_empty,
        parse_char(" "),
        parse_char("\n"),
        parse_char("\r"),
        parse_char("\t"),
    )(s)

def parse_true(s):
    return sequence(
        parse_char("t"),
        parse_char("r"),
        parse_char("u"),
        parse_char("e"),
    )(s)

def parse_false(s):
    return sequence(
        parse_char("f"),
        parse_char("a"),
        parse_char("l"),
        parse_char("s"),
        parse_char("e"),
    )(s)

def parse_null(s):
    return sequence(
        parse_char("n"),
        parse_char("u"),
        parse_char("l"),
        parse_char("l"),
    )(s)

def parse_almost_any_char(s):  # TODO
    input = s["input"]
    end = len(input)
    idx = s["index"]
    if idx >= end or input[idx] == '"' or input[idx] == "\\":
        return set()
    return set([idx + 1])

# custom

def parse_empty(s):
    return set([s["index"]])

def parse_char(c):
    def f(s):
        input = s["input"]
        end = len(input)
        idx = s["index"]
        if idx >= end or input[idx] != c:
            return set()
        return set([idx + 1])

    return f

def alternate(*ps):
    def f(s):
        res = set()
        for p in ps:
            idxs = p(s)
            res = res.union(idxs)
        return res

    return f

def sequence(*ps):
    def f(s):
        s1 = copy(s)
        idxs = set([s1["index"]])
        for p in ps:
            new_idxs = set()
            for idx in idxs:
                s1["index"] = idx
                curr_idxs = p(s1)
                new_idxs = new_idxs.union(curr_idxs)
            idxs = new_idxs
            if len(idxs) == 0:
                break
        return idxs

    return f

def copy(s):
    return {
        "input": s["input"],
        "index": s["index"],
    }
