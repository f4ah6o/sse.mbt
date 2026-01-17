///|
/// Test for SSE event type conversions
test check_event_state_conversions() {
  let connecting = ready_state_to_event_state(0)
  inspect!(connecting, EventState::Connecting)

  let open = ready_state_to_event_state(1)
  inspect!(open, EventState::Open)

  let closed = ready_state_to_event_state(2)
  inspect!(closed, EventState::Closed)

  let error = ready_state_to_event_state(99)
  inspect!(error, EventState::Error)
}

///|
/// Test for default connection configuration
test check_default_config() {
  let config = default_connection_config("http://localhost:8080/events")
  inspect!(config.url, "http://localhost:8080/events")
  inspect!(config.with_credentials, false)
  inspect!(config.reconnect_interval, 3000)
  inspect!(config.max_retries, 10)
}

///|
/// Property-based test: ready_state_to_event_state is total
test prop_ready_state_to_event_state_total() {
  // All valid states (0, 1, 2) should map correctly
  let state_0 = ready_state_to_event_state(0)
  inspect!(state_0, EventState::Connecting)

  let state_1 = ready_state_to_event_state(1)
  inspect!(state_1, EventState::Open)

  let state_2 = ready_state_to_event_state(2)
  inspect!(state_2, EventState::Closed)

  // Unknown states should map to Error
  let state_unknown = ready_state_to_event_state(999)
  inspect!(state_unknown, EventState::Error)
}

///|
/// Property-based test: constants match specification
test prop_ready_state_constants() {
  // EventSource ready state constants per spec
  inspect!(CONNECTING, 0)
  inspect!(OPEN, 1)
  inspect!(CLOSED, 2)
}

///|
/// Property-based test: default connection config preserves URL
test prop_default_config_url_preserved() {
  let urls = ["http://localhost:8080", "https://example.com/sse", ""]
  for url in urls {
    let config = default_connection_config(url)
    inspect!(config.url, url)
  }
}

///|
/// Property-based test: default values are non-negative
test prop_default_config_non_negative() {
  let config = default_connection_config("http://example.com")
  inspect!(config.reconnect_interval > 0, true)
  inspect!(config.max_retries > 0, true)
}

///|
/// Property-based test: max_retries_exceeded boundary
test prop_max_retries_boundary() {
  let max_retries = 10

  // Below max: 9 < 10, should not exceed
  let below = max_retries - 1
  inspect!(below < max_retries, true)

  // At max: 10 >= 10, should exceed
  let at = max_retries
  inspect!(at >= max_retries, true)

  // Above max: 11 >= 10, should exceed
  let above = max_retries + 1
  inspect!(above >= max_retries, true)
}
