local ffi = require( "ffi" )

local libs = ffi_zmq_libs or {
   OSX     = { x86 = "bin/OSX/zmq.dylib", x64 = "bin/OSX/zmq.dylib" },
   Windows = { x86 = "libzmq.dll", x64 = "bin/Windows/x64/zmq.dll" },
   Linux   = { x86 = "zmq.so", x64 = "bin/Linux/x64/zmq.so", arm = "bin/Linux/arm/zmq.so"  },
}

local zmq = ffi.load( ffi_zmq_lib or libs[ ffi.os ][ ffi.arch ] )

ffi.cdef([[
   enum {
      ZMQ_VERSION_MAJOR       = 0,
      ZMQ_VERSION_MINOR       = 0,
      ZMQ_VERSION_PATCH       = 0,
      ZMQ_VERSION             = ZMQ_VERSION_MAJOR * 10000 + ZMQ_VERSION_MINOR * 100 + ZMQ_VERSION_PATCH,
      
      ZMQ_HAUSNUMERO          = 156384712,

      ZMQ_IO_THREADS          = 1,    // Option index
      ZMQ_IO_THREADS_DFLT     = 1,    // Default value

      ZMQ_MAX_SOCKETS         = 2,    // Option index
      ZMQ_MAX_SOCKETS_DFLT    = 1024, // Default value

      // Socket types
      ZMQ_PAIR                = 0,
      ZMQ_PUB                 = 1,
      ZMQ_SUB                 = 2,
      ZMQ_REQ                 = 3,
      ZMQ_REP                 = 4,
      ZMQ_DEALER              = 5,
      ZMQ_ROUTER              = 6,
      ZMQ_PULL                = 7,
      ZMQ_PUSH                = 8,
      ZMQ_XPUB                = 9,
      ZMQ_XSUB                = 10,

      // Socket options
      ZMQ_AFFINITY            = 4,
      ZMQ_SUBSCRIBE           = 6,
      ZMQ_UNSUBSCRIBE         = 7,
      ZMQ_RATE                = 8,
      ZMQ_RECOVERY_IVL        = 9,
      ZMQ_SNDBUF              = 11,
      ZMQ_RCVBUF              = 12,
      ZMQ_RCVMORE             = 13,
      ZMQ_FD                  = 14,
      ZMQ_EVENTS              = 15,
      ZMQ_TYPE                = 16,
      ZMQ_LINGER              = 17,
      ZMQ_RECONNECT_IVL       = 18,
      ZMQ_BACKLOG             = 19,
      ZMQ_RECONNECT_IVL_MAX   = 21,
      ZMQ_MAXMSGSIZE          = 22,
      ZMQ_SNDHWM              = 23,
      ZMQ_RCVHWM              = 24,
      ZMQ_MULTICAST_HOPS      = 25,
      ZMQ_RCVTIMEO            = 27,
      ZMQ_SNDTIMEO            = 28,
      ZMQ_IPV4ONLY            = 31,
      ZMQ_LAST_ENDPOINT       = 32,
      ZMQ_FAIL_UNROUTABLE     = 33,
      ZMQ_TCP_KEEPALIVE       = 34,
      ZMQ_TCP_KEEPALIVE_CNT   = 35,
      ZMQ_TCP_KEEPALIVE_IDLE  = 36,
      ZMQ_TCP_KEEPALIVE_INTVL = 37,
      ZMQ_TCP_ACCEPT_FILTER   = 38,
      ZMQ_DELAY_ATTACH_ON_CONNECT = 39,
      ZMQ_XPUB_VERBOSE        = 40,

      // Message options
      ZMQ_MORE                = 1,
    
      // Send/recv options
      ZMQ_DONTWAIT            = 1,
      ZMQ_SNDMORE             = 2,

      // I/O multiplexing
      ZMQ_POLLIN              = 1,
      ZMQ_POLLOUT             = 2, 
      ZMQ_POLLERR             = 4,

      // Devices - Experimental
      ZMQ_STREAMER            = 1,
      ZMQ_FORWARDER           = 2,
      ZMQ_QUEUE               = 4,
   }

   typedef struct zmq_socket_t* zmq_socket_t;
   typedef struct zmq_ctx_t*    zmq_ctx_t;

   typedef struct zmq_pollitem_t {
      void* socket;
]] .. (ffi.os == "Windows" and "void*" or "int") .. [[ fd;
      short events;
      short revents;
   } zmq_pollitem_t;

   typedef struct zmq_msg_t {
      unsigned char _ [32];
   } zmq_msg_t;

   typedef struct zmq_iovec_t {
      void *iov_base;
      size_t iov_len;
   } zmq_iovec_t;

   typedef void (zmq_free_fn)(        void *data, void *hint );

   int           zmq_errno(           );
   const char*   zmq_strerror(        int errnum );

   zmq_ctx_t     zmq_ctx_new(         );
   int           zmq_ctx_destroy(     zmq_ctx_t );
   int           zmq_ctx_set(         zmq_ctx_t, int option, int optval );
   int           zmq_ctx_get(         zmq_ctx_t, int option  );

   zmq_ctx_t     zmq_init(            int io_threads );
   int           zmq_term(            zmq_ctx_t context );

   void          zmq_version(         int* major, int* minor, int* patch );

   int           zmq_msg_init(        zmq_msg_t*  );
   int           zmq_msg_init_size(   zmq_msg_t*, size_t size );
   int           zmq_msg_init_data(   zmq_msg_t*, void* data, size_t size, zmq_free_fn*, void* hint );
   int           zmq_msg_send(        zmq_msg_t*, zmq_socket_t s, int flags );
   int           zmq_msg_recv(        zmq_msg_t*, zmq_socket_t s, int flags );
   int           zmq_msg_close(       zmq_msg_t*  );
   int           zmq_msg_move(        zmq_msg_t*  dst, zmq_msg_t* src );
   int           zmq_msg_copy(        zmq_msg_t*  dst, zmq_msg_t* src );
   void*         zmq_msg_data(        zmq_msg_t*  );
   size_t        zmq_msg_size(        zmq_msg_t*  );
   int           zmq_msg_more(        zmq_msg_t*  );
   int           zmq_msg_get(         zmq_msg_t*, int option );
   int           zmq_msg_set(         zmq_msg_t*, int option, int optval );

   zmq_socket_t  zmq_socket(          zmq_ctx_t,    int type );
   int           zmq_close(           zmq_socket_t  );
   int           zmq_setsockopt(      zmq_socket_t, int option, const void *optval, size_t  optvallen ); 
   int           zmq_getsockopt(      zmq_socket_t, int option,       void *optval, size_t* optvallen );
   int           zmq_bind(            zmq_socket_t, const char *addr );
   int           zmq_unbind(          zmq_socket_t, const char *addr );
   int           zmq_connect(         zmq_socket_t, const char *addr );
   int           zmq_disconnect(      zmq_socket_t, const char *addr );
   int           zmq_send(            zmq_socket_t, const void* buf, int len, int flags );
   int           zmq_recv(            zmq_socket_t,       void* buf, int len, int flags );
   int           zmq_socket_monitor(  zmq_socket_t, const char* addr, int events );

   int           zmq_sendmsg(         zmq_socket_t, zmq_msg_t* msg, int flags );
   int           zmq_recvmsg(         zmq_socket_t, zmq_msg_t* msg, int flags );

   int           zmq_sendiov(         zmq_socket_t, zmq_iovec_t* iov, size_t  count, int flags );
   int           zmq_recviov(         zmq_socket_t, zmq_iovec_t* iov, size_t *count, int flags );
   
   int           zmq_poll(            zmq_pollitem_t* items, int nitems, long timeout );
   int           zmq_proxy(           void* frontend, void* backend, void* capture );

   int           zmq_device(          int device, void* insocket, void* outsocket );

   void*         zmq_stopwatch_start( void );
   unsigned long zmq_stopwatch_stop(  void *watch );
   
   void          zmq_sleep(           int seconds );
]])

return zmq
