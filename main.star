load("lib.star", "parse_json")

def main():
    json_str = """
    {   
        "foo" :"bar",
        "yo":42
    }"""
    print(
        parse_json(
            {
                "input": json_str,
                "index": 0,
            },
        ),
    )

main()
