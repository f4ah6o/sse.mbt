///|
/// Bounded alphabet: no CR in data; no CR/LF/NUL in event names or IDs.
/// Bytes and their tuples use core QuickCheck's official generators/shrinkers.
fn field_text(bytes : Array[Byte], multiline : Bool) -> String {
  let alphabet = if multiline {
    ["a", "Z", "0", ":", " ", "\t", "é", "😀", "\n", "\u{0000}"]
  } else {
    ["a", "Z", "0", ":", " ", "\t", "é", "😀"]
  }
  let mut result = ""
  for byte in bytes {
    result += alphabet[byte.to_int() % alphabet.length()]
  }
  result
}

///|
/// Independent, test-only LF-stream interpreter for the formatter's domain.
/// WHATWG HTML 9.2.6: split at the first colon, strip at most one space,
/// append data lines, dispatch on a blank line, and retain the last event ID.
/// https://html.spec.whatwg.org/multipage/server-sent-events.html#event-stream-interpretation
/// This is not a general browser/UTF-8/CRLF parser.
fn interpret_lf_stream(wire : String) -> Array[(String, String, String)] {
  let events = []
  let mut line = ""
  let mut data = ""
  let mut event_type = ""
  let mut last_id = ""
  for char in wire.iter() {
    if char != '\n' {
      line += char.to_string()
      continue
    }
    if line == "" {
      if data != "" {
        let kind = if event_type == "" { "message" } else { event_type }
        events.push((data[:data.length() - 1].to_owned(), kind, last_id))
      }
      data = ""
      event_type = ""
    } else {
      let mut field = ""
      let mut value = ""
      let mut colon_seen = false
      let mut first_value_char = false
      for c in line.iter() {
        if !colon_seen {
          if c == ':' {
            colon_seen = true
            first_value_char = true
          } else {
            field += c.to_string()
          }
        } else {
          if !first_value_char || c != ' ' {
            value += c.to_string()
          }
          first_value_char = false
        }
      }
      match field {
        "data" => data = data + value + "\n"
        "event" => event_type = value
        "id" => if !value.contains("\u{0000}") { last_id = value }
        _ => ()
      }
    }
    line = ""
  }
  events
}

///|
test "LF interpreter known WHATWG field and dispatch vectors" {
  assert_eq(interpret_lf_stream("data: incomplete\n"), [])
  assert_eq(interpret_lf_stream(":comment\nunknown: ignored\n\n"), [])
  assert_eq(interpret_lf_stream("data\n\n"), [("", "message", "")])
  assert_eq(
    interpret_lf_stream("id: 7\ndata:  x:y\ndata:z\nevent: update\n\n"),
    [(" x:y\nz", "update", "7")],
  )
  assert_eq(
    interpret_lf_stream(
      "id: old\ndata: a\n\nid: bad\u{0000}id\nevent:\ndata: b\n\nid:\ndata: c\n\n",
    ),
    [("a", "message", "old"), ("b", "message", "old"), ("c", "message", "")],
  )
}

///|
test "format_event preserves bounded fields under WHATWG interpretation" {
  @quickcheck.check(
    fn(input : (Array[Byte], Array[Byte]?, Array[Byte]?)) {
      let (data_bytes, event_bytes, id_bytes) = input
      let data = field_text(data_bytes, true)
      let event = event_bytes.map(bytes => field_text(bytes, false))
      let id = id_bytes.map(bytes => field_text(bytes, false))
      let kind = match event {
        Some(e) if e != "" => e
        _ => "message"
      }
      let expected_id = match id {
        Some(i) => i
        None => ""
      }
      let wire = @sse.format_event({ data, event, id, })
      interpret_lf_stream(wire) == [(data, kind, expected_id)]
    },
    count=2000,
    max_size=32,
    max_shrinks=1000,
    seed=20261012,
  )
}

///|
test "format_event empty multiline whitespace and Unicode boundaries" {
  for
    (data, expected) in [
      ("", "data: \n\n"),
      ("\n", "data: \ndata: \n\n"),
      ("\n\n", "data: \ndata: \ndata: \n\n"),
      ("a\n", "data: a\ndata: \n\n"),
      ("\na", "data: \ndata: a\n\n"),
      ("  :x\t", "data:   :x\t\n\n"),
      ("é😀\u{0000}", "data: é😀\u{0000}\n\n"),
    ] {
    assert_eq(@sse.format_event(@sse.SSEEvent::data_only(data)), expected)
    assert_eq(interpret_lf_stream(expected), [(data, "message", "")])
  }
  assert_eq(
    @sse.format_event({ data: "", event: Some(""), id: Some(""), }),
    "id: \nevent: \ndata: \n\n",
  )
}
