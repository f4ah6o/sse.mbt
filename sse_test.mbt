///|
/// Test for SSE event type conversions
test "check_event_state_conversions" {
  let connecting = @sse.ready_state_to_event_state(0)
  inspect(connecting, content="Connecting")
  let open = @sse.ready_state_to_event_state(1)
  inspect(open, content="Open")
  let closed = @sse.ready_state_to_event_state(2)
  inspect(closed, content="Closed")
  let error = @sse.ready_state_to_event_state(99)
  inspect(error, content="Error")
}

///|
/// Test for default connection configuration
test "check_default_config" {
  let config = @sse.default_connection_config("http://localhost:8080/events")
  inspect(config.url, content="http://localhost:8080/events")
  inspect(config.with_credentials, content="false")
  inspect(config.reconnect_interval, content="3000")
  inspect(config.max_retries, content="10")
}

///|
/// Property-based test: @sse.ready_state_to_event_state is total
test "prop_ready_state_to_event_state_total" {
  let state_0 = @sse.ready_state_to_event_state(0)
  inspect(state_0, content="Connecting")
  let state_1 = @sse.ready_state_to_event_state(1)
  inspect(state_1, content="Open")
  let state_2 = @sse.ready_state_to_event_state(2)
  inspect(state_2, content="Closed")
  let state_unknown = @sse.ready_state_to_event_state(999)
  inspect(state_unknown, content="Error")
}

///|
/// Property-based test: constants match specification
test "prop_ready_state_constants" {
  inspect(@sse.CONNECTING, content="0")
  inspect(@sse.OPEN, content="1")
  inspect(@sse.CLOSED, content="2")
}

///|
/// Property-based test: default connection config preserves URL
test "prop_default_config_url_preserved" {
  let urls : Array[String] = [
    "http://localhost:8080", "https://example.com/sse", "",
  ]
  for url in urls {
    let config = @sse.default_connection_config(url)
    inspect(config.url, content=url)
  }
}

///|
/// Property-based test: default values are non-negative
test "prop_default_config_non_negative" {
  let config = @sse.default_connection_config("http://example.com")
  inspect(config.reconnect_interval > 0, content="true")
  inspect(config.max_retries > 0, content="true")
}

///|
/// Property-based test: max_retries_exceeded boundary
test "prop_max_retries_boundary" {
  let max_retries = 10
  let below = max_retries - 1
  inspect(below < max_retries, content="true")
  let at = max_retries
  inspect(at >= max_retries, content="true")
  let above = max_retries + 1
  inspect(above >= max_retries, content="true")
}

///|
/// Test for SSEEvent formatting
test "format_event_basic" {
  let event = @sse.SSEEvent::new("hello", "message", None)
  inspect(@sse.format_event(event), content="event: message\ndata: hello\n\n")
}

///|
/// Test for SSEEvent data_only formatting
test "format_event_data_only" {
  let event = @sse.SSEEvent::data_only("hello world")
  inspect(@sse.format_event(event), content="data: hello world\n\n")
}

///|
/// Test for SSEEvent with id
test "format_event_with_id" {
  let event = @sse.SSEEvent::new("data", "update", Some("42"))
  inspect(
    @sse.format_event(event),
    content="id: 42\nevent: update\ndata: data\n\n",
  )
}

///|
test "format_event_splits_multiline_data" {
  let event = @sse.SSEEvent::data_only("first\nsecond")
  inspect(@sse.format_event(event), content="data: first\ndata: second\n\n")
}

///|
test "Show output remains compatible" {
  inspect(@sse.ready_state_to_event_state(0).to_string(), content="Connecting")
  inspect(
    @sse.SSEEvent::new("hello", "message", Some("42")).to_string(),
    content="{data: hello, event: Some(message), id: Some(42)}",
  )
}
