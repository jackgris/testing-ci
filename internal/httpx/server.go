package httpx

import (
	"context"
	"net/http"
	"time"

	"github.com/jackgris/testing-ci/internal/config"
	"github.com/jackgris/testing-ci/internal/logx"
)

type Server struct {
	cfg    config.Config
	log    logx.Logger
	server *http.Server
}

func NewServer(cfg config.Config, log logx.Logger) *Server {
	r := NewRouter(cfg, log)

	return &Server{
		cfg: cfg,
		log: log,
		server: &http.Server{
			Addr:         cfg.HTTPAddr,
			Handler:      r,
			ReadTimeout:  time.Duration(cfg.ReadTimeoutSec) * time.Second,
			WriteTimeout: time.Duration(cfg.WriteTimeoutSec) * time.Second,
			IdleTimeout:  time.Duration(cfg.IdleTimeoutSec) * time.Second,
		},
	}
}

func (s *Server) Start() error {
	s.log.Info("http server starting", logx.String("addr", s.cfg.HTTPAddr))
	return s.server.ListenAndServe()
}

func (s *Server) Stop(ctx context.Context) error {
	s.log.Info("http server stopping")
	return s.server.Shutdown(ctx)
}
