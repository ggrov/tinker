(* Wrapped Socket interface, any implementation of socket communication,
 * no matter synchroized or asynchroized, should implement this signature.
 * This signature will be used for higher levelled communication. 
 *
 * Note, that this signature is firstly designed only to handle client server, which means any third
 * party prover should implement a server socket
 *)

signature WSOCK=
sig
  type socket
  exception Prover_cancellation
  exception Prover_exit
  (* Default port for the prover that uses this socket wrapper *)
  val default_port : int

  (* Create a client socket connection with given port number, returns the socket information *)
  val connect : unit -> socket

  (* Disconnect the socket connection of the port, third party prover may also want to be noticed  
   * before disconnection. So rather than disconnect it directly, you may want to also send a
   * disconnection message before just disconnect directly to avoid exception
   *)
  val disconnect : unit -> string

  (* Send a string through the socket, returns a string representing the status of operation.
   * This operation will probably suspend the current thread until either a string is received or
   * any exception occurs. 
   *)
  val send :  string -> unit

  (* Receive a string from the socket, returns the string.
   *)
  val receive : unit -> string
 
  (* Get the socket instance of the given port number, this function returns a socket instance,
   * In the implementation of Rodin, this function will always call connect to create a new
   * socket, because Rodin plugin for Tinker does not need a consistent socket. However, for 
   * any other prover that may need consistent socket connection, a reuse of socket by calling
   * TextSocket.safe_local_client : int -> socket to re-use the socket on the given port
  *)
  val getInstance : unit -> socket


end


