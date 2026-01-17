///|
/// EventSource type - opaque wrapper around JavaScript EventSource
pub type EventSource {
  EventSource(raw : @core.Any)
}

///|
/// Create a new EventSource connection
extern "js" fn event_source_new(url : String) -> EventSource =
  #|(url) => {
  #|  try {
  #|    const es = new EventSource(url);
  #|    return { $tag: 0, _0: es };
  #|  } catch (e) {
  #|    console.error('[sse.mbt] Failed to create EventSource:', e);
  #|    throw e;
  #|  }
  #|}

///|
/// Create a new EventSource connection with credentials option
extern "js" fn event_source_new_with_credentials(
  url : String,
  with_credentials : Bool,
) -> EventSource =
  #|(url, withCredentials) => {
  #|  try {
  #|    const es = new EventSource(url, { withCredentials: withCredentials });
  #|    return { $tag: 0, _0: es };
  #|  } catch (e) {
  #|    console.error('[sse.mbt] Failed to create EventSource:', e);
  #|    throw e;
  #|  }
  #|}

///|
/// Close an EventSource connection
extern "js" fn event_source_close(es : EventSource) -> Unit =
  #|(es) => {
  #|  if (es && es._0 && typeof es._0.close === 'function') {
  #|    es._0.close();
  #|  }
  #|}

///|
/// Get the ready state of an EventSource connection
extern "js" fn event_source_ready_state(es : EventSource) -> Int =
  #|(es) => {
  #|  if (es && es._0 && typeof es._0.readyState !== 'undefined') {
  #|    return es._0.readyState;
  #|  }
  #|  return 3; // CLOSED
  #|}

///|
/// EventSource ready state constants
pub const CONNECTING : Int = 0
pub const OPEN : Int = 1
pub const CLOSED : Int = 2

///|
/// Convert ready state to EventState
pub fn ready_state_to_event_state(state : Int) -> EventState {
  match state {
    0 => EventState::Connecting
    1 => EventState::Open
    2 => EventState::Closed
    _ => EventState::Error
  }
}

///|
/// Add event listener for a specific event name
extern "js" fn event_source_add_listener(
  es : EventSource,
  event_name : String,
  handler : @core.Any,
) -> Unit =
  #|(es, eventName, handler) => {
  #|  if (es && es._0 && typeof es._0.addEventListener === 'function') {
  #|    es._0.addEventListener(eventName, handler);
  #|  }
  #|}

///|
/// Remove event listener for a specific event name
extern "js" fn event_source_remove_listener(
  es : EventSource,
  event_name : String,
  handler : @core.Any,
) -> Unit =
  #|(es, eventName, handler) => {
  #|  if (es && es._0 && typeof es._0.removeEventListener === 'function') {
  #|    es._0.removeEventListener(eventName, handler);
  #|  }
  #|}

///|
/// Add onopen handler
extern "js" fn event_source_on_open(es : EventSource, handler : @core.Any) -> Unit =
  #|(es, handler) => {
  #|  if (es && es._0) {
  #|    es._0.onopen = handler;
  #|  }
  #|}

///|
/// Add onerror handler
extern "js" fn event_source_on_error(es : EventSource, handler : @core.Any) -> Unit =
  #|(es, handler) => {
  #|  if (es && es._0) {
  #|    es._0.onerror = handler;
  #|  }
  #|}

///|
/// Add onmessage handler
extern "js" fn event_source_on_message(es : EventSource, handler : @core.Any) -> Unit =
  #|(es, handler) => {
  #|  if (es && es._0) {
  #|    es._0.onmessage = handler;
  #|  }
  #|}

///|
/// Get the URL of an EventSource
extern "js" fn event_source_url(es : EventSource) -> String =
  #|(es) => {
  #|  if (es && es._0 && typeof es._0.url === 'string') {
  #|    return es._0.url;
  #|  }
  #|  return '';
  #|}
