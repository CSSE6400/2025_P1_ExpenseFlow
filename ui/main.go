package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

var config map[string]string

func mustEnv(keyName string) string {
	val, exists := os.LookupEnv(keyName)
	if !exists {
		log.Fatalf("Missing env var: %s", keyName)
	}
	return val
}

func configHandler(w http.ResponseWriter, _ *http.Request) {
	log.Print("Retrieving app config...")
	w.Header().Set("Content-Type", "application/json")
	err := json.NewEncoder(w).Encode(config)
	if err != nil {
		http.Error(w, "Failed to encode config", http.StatusInternalServerError)
	}
}

func main() {

	config = map[string]string{
		"BACKEND_BASE_URL": mustEnv("BACKEND_BASE_URL"),
	}

	fs := http.FileServer(http.Dir("./static"))
	http.HandleFunc("/config", configHandler)
	http.Handle("/", fs)

	s := &http.Server{
		Addr:    ":3000",
		Handler: nil,
	}

	log.Print("Listening on :3000...")
	err := s.ListenAndServe()
	if err != nil {
		log.Fatal(err)
	}
}
