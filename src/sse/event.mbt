///|
/// SSE Event State enumeration
pub enum EventState {
  Connecting
  Open
  Closed
  Error
}

///|
/// SSE Message structure
pub struct SseMessage {
  event_name : String
  data : String
  origin : String
  id : String?
}

///|
/// Connection configuration for SSE
pub struct ConnectionConfig {
  url : String
  with_credentials : Bool
  reconnect_interval : Int
  max_retries : Int
}

///|
/// Default connection configuration
pub fn default_connection_config(url : String) -> ConnectionConfig {
  { url: url, with_credentials: false, reconnect_interval: 3000, max_retries: 10 }
}

///|
/// Event handler type for SSE events
pub type EventHandler = (SseMessage) -> Unit

///|
/// Connection state handler type
pub type ConnectionStateHandler = (EventState) -> Unit

///|
/// Error handler type for SSE errors
pub type ErrorHandler = (@core.Any) -> Unit
