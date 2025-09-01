package httpx

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/jackgris/testing-ci/internal/config"
	"github.com/jackgris/testing-ci/internal/httpx/handlers"
	"github.com/jackgris/testing-ci/internal/logx"
)

func NewRouter(cfg config.Config, log logx.Logger) http.Handler {
	r := chi.NewRouter()

	// Standard middlewares
	r.Use(middleware.RequestID)
	r.Use(middleware.RealIP)
	r.Use(middleware.Recoverer)
	r.Use(middleware.Heartbeat("/live")) // k8s style liveness probe
	r.Use(RequestLogger(log))            // structured request logging

	// Routes
	r.Route("/api", func(r chi.Router) {
		r.Get("/health", handlers.Health())
	})

	return r
}
