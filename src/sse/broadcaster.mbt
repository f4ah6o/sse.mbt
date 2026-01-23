// Server-side SSE broadcaster for native target

///|
pub struct Broadcaster {
  mutable connections : Array[ServerConnection]
}

///|
pub fn Broadcaster::new() -> Broadcaster {
  { connections: [] }
}

///|
pub fn subscribe(b : Broadcaster, conn : ServerConnection) -> Unit {
  b.connections.push(conn)
}

///|
pub fn broadcast(b : Broadcaster, formatted_event : String) -> Unit {
  let mut alive_connections : Array[ServerConnection] = []
  for conn in b.connections {
    if send_event(conn, formatted_event) {
      alive_connections.push(conn)
    }
  }
  b.connections = alive_connections
}

///|
pub fn remove_closed(b : Broadcaster) -> Unit {
  b.connections = b.connections.filter(fn(c) { c.is_alive })
}

///|
fn send_event(conn : ServerConnection, formatted_event : String) -> Bool {
  if !conn.is_alive {
    return false
  }
  write_string(conn, formatted_event)
}
