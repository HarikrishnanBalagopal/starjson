def parse_json(s):
    return parse_element(s)

def parse_value(s):
    return alternate(
        "value",
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
        "object",
        sequence(
            "object-1",
            parse_char("{"),
            parse_whitespace,
            parse_char("}"),
        ),
        sequence(
            "object-2",
            parse_char("{"),
            parse_members,
            parse_char("}"),
        ),
    )(s)

def parse_members(s):
    return alternate(
        "members",
        parse_member,
        sequence(
            "members-1",
            parse_member,
            parse_char(","),
            parse_members,
        ),
    )(s)

def parse_member(s):
    return sequence(
        "member",
        parse_whitespace,
        parse_string,
        parse_whitespace,
        parse_char(":"),
        parse_element,
    )(s)

def parse_array(s):
    return alternate(
        "array",
        sequence(
            "array-1",
            parse_char("["),
            parse_whitespace,
            parse_char("]"),
        ),
        sequence(
            "array-2",
            parse_char("["),
            parse_elements,
            parse_char("]"),
        ),
    )(s)

def parse_elements(s):
    return alternate(
        "elements",
        parse_element,
        sequence(
            "elements-1",
            parse_element,
            parse_char(","),
            parse_elements,
        ),
    )(s)

def parse_element(s):
    return sequence(
        "element",
        parse_whitespace,
        parse_value,
        parse_whitespace,
    )(s)

def parse_string(s):
    return sequence(
        "string",
        parse_char('"'),
        parse_characters,
        parse_char('"'),
    )(s)

def parse_characters(s):
    return alternate(
        "characters",
        parse_empty,
        sequence(
            "characters-1",
            parse_character,
            parse_characters,
        ),
    )(s)

def parse_character(s):
    return alternate(
        "character",
        parse_almost_any_char,
        sequence(
            "character-1",
            parse_char("\\"),
            parse_escape,
        ),
    )(s)

def parse_escape(s):
    return alternate(
        "escape",
        parse_char('"'),
        parse_char("\\"),
        parse_char("b"),
        parse_char("f"),
        parse_char("n"),
        parse_char("r"),
        parse_char("t"),
        sequence(
            "escape-1",
            parse_char("u"),
            parse_hex,
            parse_hex,
            parse_hex,
            parse_hex,
        ),
    )(s)

def parse_hex(s):
    return alternate(
        "hex",
        parse_digit,
        alternate(
            "hex-1",
            parse_char("A"),
            parse_char("B"),
            parse_char("C"),
            parse_char("D"),
            parse_char("E"),
            parse_char("F"),
        ),
        alternate(
            "hex-2",
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
        "number",
        parse_integer,
        parse_fraction,
        parse_exponent,
    )(s)

def parse_integer(s):
    return alternate(
        "integer",
        parse_digit,
        sequence(
            "integer-1",
            parse_onenine,
            parse_digits,
        ),
        sequence(
            "integer-2",
            parse_char("-"),
            parse_digit,
        ),
        sequence(
            "integer-3",
            parse_char("-"),
            parse_onenine,
            parse_digits,
        ),
    )(s)

def parse_digits(s):
    return alternate(
        "digits",
        parse_digit,
        sequence(
            "digits-1",
            parse_digit,
            parse_digits,
        ),
    )(s)

def parse_digit(s):
    return alternate(
        "digit",
        parse_char("0"),
        parse_onenine,
    )(s)

def parse_onenine(s):
    return alternate(
        "onenine",
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
        "fraction",
        parse_empty,
        sequence(
            "fraction-1",
            parse_char("."),
            parse_digits,
        ),
    )(s)

def parse_exponent(s):
    return alternate(
        "exponent",
        parse_empty,
        sequence(
            "exponent-1",
            parse_char("E"),
            parse_sign,
            parse_digits,
        ),
        sequence(
            "exponent-2",
            parse_char("e"),
            parse_sign,
            parse_digits,
        ),
    )(s)

def parse_sign(s):
    return alternate(
        "sign",
        parse_empty,
        parse_char("+"),
        parse_char("-"),
    )(s)

def parse_whitespace(s):
    return alternate(
        "whitespace",
        parse_empty,
        sequence(
            "whitespace-1",
            parse_char(" "),
            parse_whitespace,
        ),
        sequence(
            "whitespace-2",
            parse_char("\n"),
            parse_whitespace,
        ),
        sequence(
            "whitespace-3",
            parse_char("\r"),
            parse_whitespace,
        ),
        sequence(
            "whitespace-4",
            parse_char("\t"),
            parse_whitespace,
        ),
    )(s)

def parse_true(s):
    return sequence(
        "true",
        parse_char("t"),
        parse_char("r"),
        parse_char("u"),
        parse_char("e"),
    )(s)

def parse_false(s):
    return sequence(
        "false",
        parse_char("f"),
        parse_char("a"),
        parse_char("l"),
        parse_char("s"),
        parse_char("e"),
    )(s)

def parse_null(s):
    return sequence(
        "null",
        parse_char("n"),
        parse_char("u"),
        parse_char("l"),
        parse_char("l"),
    )(s)

# custom

def parse_almost_any_char(s):  # TODO
    input = s["input"]
    end = len(input)
    idx = s["index"]
    if idx >= end or input[idx] == '"' or input[idx] == "\\":
        return {"type": "almost_any_char", "value": None, "idxs": set()}
    return {"type": "almost_any_char", "value": input[idx], "idxs": set([idx + 1])}

def parse_empty(s):
    return {"type": "empty", "value": "", "idxs": set([s["index"]])}

def parse_char(c):
    def f(s):
        input = s["input"]
        end = len(input)
        idx = s["index"]
        if idx >= end or input[idx] != c:
            return {"type": "char", "value": c, "idxs": set()}
        return {"type": "char", "value": c, "idxs": set([idx + 1])}

    return f

def alternate(p_type, *ps):
    def f(s):
        res = set()
        vs = []
        for p in ps:
            curr_res = p(s)
            idxs = curr_res["idxs"]
            res = res.union(idxs)
            if len(idxs) > 0:
                vs.append(curr_res)
        return {"type": p_type, "value": vs, "idxs": res}

    return f

def sequence(p_type, *ps):
    def f(s):
        s1 = copy(s)
        idxs = set([s1["index"]])
        vs = []
        for p in ps:
            sub_vs = []
            new_idxs = set()
            for idx in idxs:
                s1["index"] = idx
                curr_res = p(s1)
                curr_idxs = curr_res["idxs"]
                new_idxs = new_idxs.union(curr_idxs)
                if len(new_idxs) > 0:
                    sub_vs.append(curr_res)
            idxs = new_idxs
            if len(idxs) == 0:
                break
            vs.append(sub_vs)
        return {"type": p_type, "value": vs, "idxs": idxs}

    return f

def copy(s):
    return {
        "input": s["input"],
        "index": s["index"],
    }
