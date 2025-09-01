package logx

import "go.uber.org/zap"

type Logger = *zap.Logger

func New(env string) Logger {
	if env == "prod" {
		l, _ := zap.NewProduction()
		return l
	}
	l, _ := zap.NewDevelopment()
	return l
}

// Helpers for structured logging.
func String(k, v string) zap.Field  { return zap.String(k, v) }
func Int(k string, v int) zap.Field { return zap.Int(k, v) }
func Error(err error) zap.Field     { return zap.Error(err) }
