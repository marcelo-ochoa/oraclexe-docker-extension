package main

import (
	"flag"
	"log"
	"net"
	"net/http"
	"crypto/tls"
	"os"

	"github.com/labstack/echo"
	"github.com/sirupsen/logrus"
)

func main() {
	var socketPath string
	flag.StringVar(&socketPath, "socket", "/run/guest-services/oraclexe-docker-extension.sock", "Unix domain socket to listen on")
	flag.Parse()

	os.RemoveAll(socketPath)

	logrus.New().Infof("Starting listening on %s", socketPath)
	router := echo.New()
	router.HideBanner = true

	startURL := ""

	ln, err := listen(socketPath)
	if err != nil {
		log.Fatal(err)
	}
	router.Listener = ln

	router.GET("/ready", ready)

	log.Fatal(router.Start(startURL))
}

func listen(path string) (net.Listener, error) {
	return net.Listen("unix", path)
}

// ready checks whether PGAdmin is ready or not by querying localhost:9880.
func ready(ctx echo.Context) error {
	http.DefaultTransport.(*http.Transport).TLSClientConfig = &tls.Config{InsecureSkipVerify: true}
	url := "https://oraclexe:5500/em/login" // "oraclexe" is the name of the service defined in docker-compose.yml
	resp, err := http.Get(url)
	if err != nil {
		log.Println(err)
		return ctx.String(http.StatusOK, "false")

	}
	defer resp.Body.Close()

	return ctx.String(resp.StatusCode, "true")

	// return ctx.JSON(http.StatusOK, HTTPMessageBody{Message: "hello from HTTP"})

}

type HTTPMessageBody struct {
	Message string `json:"message"`
	Body    string `json:"body,omitempty"`
}
