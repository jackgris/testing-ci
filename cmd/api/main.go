package main

import (
	"context"
	"os/signal"
	"syscall"
	"time"

	"github.com/jackgris/testing-ci/internal/config"
	"github.com/jackgris/testing-ci/internal/httpx"
	"github.com/jackgris/testing-ci/internal/logx"
	"go.uber.org/zap"
)

func main() {
	cfg := config.Load()
	logger := logx.New(cfg.Env)
	defer func() { _ = logger.Sync() }()

	srv := httpx.NewServer(cfg, logger)

	// graceful shutdown
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	go func() {
		if err := srv.Start(); err != nil {
			logger.Fatal("server exited with error", logx.Error(err))
		}
	}()

	<-ctx.Done()
	stop()

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Stop(shutdownCtx); err != nil {
		logger.Error("graceful shutdown failed", zapError(err))
	} else {
		logger.Info("server stopped")
	}
}

// zapError is a small helper to avoid importing zap in main.
func zapError(err error) zap.Field { return zap.Field{Key: "error", Interface: err} }
