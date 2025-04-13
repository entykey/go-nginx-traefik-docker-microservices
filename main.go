package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/", DoHealthCheck).Methods("GET")
	router.HandleFunc("/api/go", GoServiceHandler).Methods("GET")
	log.Fatal(http.ListenAndServe(":8080", router))
}

func DoHealthCheck(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello, i'm a golang microservice")
}

func GoServiceHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "API response from Go service")
}
