(** Rpc client and server patterns *)
open Async.Std

(** Rpc Client pattern *)
module Client :
  sig
    type t

    (** Initialize a client with the [id] for tracing *)
    val init : id:string -> Amqp_connection.t -> t Deferred.t

    (** Make an rpc call to the exchange using the routing key.
        @param ttl is the message timeout.

        To call directly to a named queue, use
        [call t Exchange.default ~routing_key:"name_of_the_queue" ]
    *)
    val call :
      t ->
      ttl:int ->
      routing_key:string ->
      Amqp_exchange.t ->
      Amqp_spec.Basic.Content.t * string ->
      Amqp_message.message option Async.Std.Deferred.t

    (** Release resources *)
    val close : t -> unit Deferred.t
  end

(** Rpc Server pattern *)
module Server :
  sig
    type t

    (** Start an rpc server procucing replies for requests comming in
        on the given queue.
        @param async If true muliple request can be handled concurrently.
                     If false message are handled synchroniously (default)
    *)
    val start :
      ?async:bool ->
      Amqp_channel.t ->
      Amqp_queue.t ->
      (Amqp_message.message -> Amqp_message.message Deferred.t) -> t Deferred.t

    (** Stop the server *)
    val stop : t -> unit Deferred.t
  end
