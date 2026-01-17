# sse.mbt

Server-Sent Events (SSE) support for MoonBit/JS.

## Overview

This library provides a type-safe interface to the browser's [EventSource API](https://developer.mozilla.org/en-US/docs/Web/API/EventSource) for receiving server-sent events in MoonBit applications targeting JavaScript.

## Features

- Type-safe SSE client implementation
- Fluent API for event handler registration
- Automatic reconnection with configurable retry logic
- Connection state management
- Event message parsing with optional ID tracking
- Property-based testing coverage

## Installation

Add to your `moon.mod.json`:

```json
{
  "deps": {
    "f4ah6o/sse": "*"
  }
}
```

## Module Structure

```
src/sse/
├── event.mbt       - Core types and handlers
├── event_source.mbt - EventSource FFI bindings
├── connection.mbt  - Connection management
├── handler.mbt     - Event handler registration
└── reconnection.mbt - Auto-reconnection logic
```

## Usage

### Basic Connection

```moonbit
import sse.{connect, on_message, on_error, on_open, close}

test "basic_sse_connection" {
  let conn = connect("http://localhost:8080/events")

  conn
    |> on_message(fn(msg) {
      // Handle incoming message
      println("Received: \{msg.data}")
    })
    |> on_error(fn(err) {
      // Handle errors
      println("Error: \{err}")
    })
    |> on_open(fn(_state) {
      println("Connection opened")
    })

  // Close when done
  close(conn)
}
```

### Custom Configuration

```moonbit
import sse.{
  default_connection_config, connect_with_config, on_message
}

test "configured_connection" {
  let config = {
    ...default_connection_config("http://localhost:8080/events")
    with_credentials: true
    reconnect_interval: 5000
    max_retries: 5
  }

  let conn = connect_with_config(config)
    |> on_message(fn(msg) {
      println("Event: \{msg.event_name}, Data: \{msg.data}")
    })
}
```

### Named Event Handlers

```moonbit
import sse.{connect, on}

test "named_events" {
  let conn = connect("http://localhost:8080/events")

  conn
    |> on("notification", fn(msg) {
      println("Notification: \{msg.data}")
    })
    |> on("update", fn(msg) {
      println("Update: \{msg.data}")
    })
}
```

### Automatic Reconnection

```moonbit
import sse.{connect, setup_auto_reconnect, on_message}

test "auto_reconnect" {
  let conn = connect("http://localhost:8080/events")
    |> setup_auto_reconnect
    |> on_message(fn(msg) {
      println("Received: \{msg.data}")
    })

  // Will automatically reconnect on connection loss
  // up to max_retries times with reconnect_interval delay
}
```

### Connection State Monitoring

```moonbit
import sse.{connect, get_connection_state, is_open, is_closed}

test "check_state" {
  let conn = connect("http://localhost:8080/events")

  match get_connection_state(conn) {
    EventState::Connecting => println("Connecting...")
    EventState::Open => println("Connected")
    EventState::Closed => println("Closed")
    EventState::Error => println("Error state")
  }

  let open = is_open(conn)    // Bool
  let closed = is_closed(conn) // Bool
}
```

## API Reference

### Types

| Type | Description |
|------|-------------|
| `EventState` | Connection state enumeration (`Connecting`, `Open`, `Closed`, `Error`) |
| `SseMessage` | Incoming SSE message with `event_name`, `data`, `origin`, optional `id` |
| `ConnectionConfig` | Configuration for SSE connection |
| `EventHandler` | Handler type: `(SseMessage) -> Unit` |
| `ConnectionStateHandler` | State handler type: `(EventState) -> Unit` |
| `ErrorHandler` | Error handler type: `(@core.Any) -> Unit` |
| `SseConnection` | Opaque connection type |
| `EventSource` | Opaque EventSource wrapper |

### Functions

#### Connection

- `connect(url : String) -> SseConnection` - Create connection with defaults
- `connect_with_config(config : ConnectionConfig) -> SseConnection` - Create connection with custom config
- `close(conn : SseConnection) -> Unit` - Close the connection
- `get_connection_state(conn : SseConnection) -> EventState` - Get current state
- `is_open(conn : SseConnection) -> Bool` - Check if open
- `is_closed(conn : SseConnection) -> Bool` - Check if closed
- `get_url(conn : SseConnection) -> String` - Get connection URL
- `get_config(conn : SseConnection) -> ConnectionConfig` - Get connection config

#### Event Handlers

- `on(conn, event_name, handler) -> SseConnection` - Register named event handler
- `on_message(conn, handler) -> SseConnection` - Register default "message" handler
- `on_open(conn, handler) -> SseConnection` - Register connection open handler
- `on_error(conn, handler) -> SseConnection` - Register error handler
- `off(conn, event_name, handler) -> SseConnection` - Unregister handler

#### Reconnection

- `setup_auto_reconnect(conn) -> SseConnection` - Enable auto-reconnection
- `reconnect(conn) -> Unit` - Manually trigger reconnection

#### Configuration

- `default_connection_config(url : String) -> ConnectionConfig` - Create default config

## Testing

Run tests with:

```bash
moon test --target js
```

Update snapshots after behavioral changes:

```bash
moon test --target js --update
```

## Dependencies

- `mizchi/js` - JavaScript platform bindings for MoonBit

## License

Apache-2.0
