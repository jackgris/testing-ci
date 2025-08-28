package httpx

import (
	"net/http"
	"time"

	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackgris/testing-ci/internal/logx"
)

// RequestLogger logs method, path, status, duration, and request id using zap.
func RequestLogger(log logx.Logger) func(next http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ww := middleware.NewWrapResponseWriter(w, r.ProtoMajor)
			start := time.Now()
			next.ServeHTTP(ww, r)
			dur := time.Since(start)
			log.Info("http_request",
				logx.String("method", r.Method),
				logx.String("path", r.URL.Path),
				logx.Int("status", ww.Status()),
				logx.String("request_id", middleware.GetReqID(r.Context())),
				logx.Int("duration_ms", int(dur.Milliseconds())),
			)

		})
	}
}
