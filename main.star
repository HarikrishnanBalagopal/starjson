load("lib.star", "parse_json")

def main():
    json_str = """{"foo":"bar"}"""
    print(
        parse_json(
            {
                "input": json_str,
                "index": 0,
            },
        ),
    )

main()
