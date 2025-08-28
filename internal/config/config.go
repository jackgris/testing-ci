package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	Env             string // dev, prod, test
	HTTPAddr        string // host:port
	ReadTimeoutSec  int
	WriteTimeoutSec int
	IdleTimeoutSec  int
}

func Load() Config {
	// Load .env if present
	_ = godotenv.Load()

	cfg := Config{
		Env:             getenv("APP_ENV", "dev"),
		HTTPAddr:        getenv("HTTP_ADDR", ":8080"),
		ReadTimeoutSec:  getenvInt("READ_TIMEOUT_SEC", 10),
		WriteTimeoutSec: getenvInt("WRITE_TIMEOUT_SEC", 10),
		IdleTimeoutSec:  getenvInt("IDLE_TIMEOUT_SEC", 60),
	}
	return cfg
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func getenvInt(key string, def int) int {
	if v := os.Getenv(key); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			return n
		}
		log.Printf("invalid int for %s: %q, using default %d", key, v, def)
	}
	return def
}
