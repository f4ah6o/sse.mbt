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
