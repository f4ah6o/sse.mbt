// Server-side SSE event formatting for native target

///|
pub(all) struct SSEEvent {
  data : String
  event : String?
  id : String?
} derive(Show, Eq)

///|
pub fn SSEEvent::new(data : String, event : String, id : String?) -> SSEEvent {
  { data, event: Some(event), id }
}

///|
pub fn SSEEvent::data_only(data : String) -> SSEEvent {
  { data, event: None, id: None }
}

///|
pub fn format_event(event : SSEEvent) -> String {
  let mut result = ""
  match event.id {
    Some(id) => result = result + "id: " + id + "\n"
    None => ()
  }
  match event.event {
    Some(e) => result = result + "event: " + e + "\n"
    None => ()
  }
  // データに改行が含まれる場合、複数行のdata:フィールドに分割
  let data_lines = event.data.split("\n")
  for line_view in data_lines {
    // StringViewを文字列に変換
    let line = string_view_to_string(line_view)
    result = result + "data: " + line + "\n"
  }
  result + "\n"
}

// StringViewをStringに変換するヘルパー関数
fn string_view_to_string(sv : StringView) -> String {
  let mut result = ""
  for c in sv {
    result = result + c.to_string()
  }
  result
}
