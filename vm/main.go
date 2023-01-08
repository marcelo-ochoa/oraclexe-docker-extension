package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"time"

	"github.com/labstack/echo"
	"github.com/sirupsen/logrus"
)

var ttyd TTYD
var globaltheme Theme

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

	ttyd = TTYD{}

	router.GET("/ready", ready)
	router.POST("/start", start)

	log.Fatal(router.Start(startURL))
}

func listen(path string) (net.Listener, error) {
	return net.Listen("unix", path)
}

// ready checks whether PGAdmin is ready or not by querying localhost:9880.
func ready(ctx echo.Context) error {
	timeout := 5 * time.Second
	conn, err := net.DialTimeout("tcp", "oraclexe:1521", timeout)
	if err != nil {
		log.Println(err)
		return ctx.String(http.StatusOK, "false")

	}

	if conn != nil {
		conn.Close()
	}

	if ttyd.IsRunning() {
		return ctx.String(http.StatusOK, "true")
	}

	return ctx.String(http.StatusServiceUnavailable, "false")
}

// start starts ttyd with the provided theme.
func start(ctx echo.Context) error {
	var newTheme Theme
	if err := ctx.Bind(&newTheme); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, err.Error())
	}
	if err := ttyd.Start(newTheme); err != nil {
		log.Printf("failed to start ttyd error is: %s\n", err)

		return echo.NewHTTPError(http.StatusInternalServerError)
	}

	return ctx.String(http.StatusOK, "true")
}

type HTTPMessageBody struct {
	Message string `json:"message"`
	Body    string `json:"body,omitempty"`
}

type Theme struct {
	Background string `json:"background" form="background" query="background"`
	Foreground string `json:"foreground" form="foreground" query="foreground"`
	Cursor     string `json:"cursor" form="cursor" query="cursor"`
	Selection  string `json:"selection" form="selection" query="selection"`
}

func (t Theme) String() string {
	b, err := json.Marshal(t)
	if err != nil {
		return ""
	}

	return string(b)
}

type TTYD struct {
	process *os.Process
}

func (t *TTYD) Start(theme Theme) error {
	if globaltheme.Background != theme.Background {
		if err := t.Stop(); err != nil {
			log.Printf("failed to stop ttyd: %s\n", err)
		}
		globaltheme = theme
	}
	if !t.IsStarted() {
		args := []string{"-u", "1000", "-g", "1000", "-t", "titleFixed='sqlcl'"}
		args = append(args, "-t", fmt.Sprintf("theme=%s", theme))
	
		args = append(args, "/bin/bash", "/home/sql.sh")
	
		cmd := exec.Command("/usr/bin/ttyd", args...)
		if err := cmd.Start(); err != nil {
			return err
		}
	
		t.process = cmd.Process
		log.Println("started ttyd with theme:", globaltheme)
	}

	return nil
}

func (t *TTYD) Stop() error {
	if !t.IsStarted() {
		return nil
	}

	if err := t.process.Kill(); err != nil {
		log.Printf("failed to stop ttyd: %s\n", err)
		return err
	}
	t.process.Wait()
    t.process = nil

	return nil
}

func (t TTYD) IsStarted() bool {
	return t.process != nil
}

func (t *TTYD) IsRunning() bool {
	if !t.IsStarted() {
		return false
	}

	url := "http://localhost:7681/" // "sqlcl" is the name of the service defined in docker-compose.yml
	resp, err := http.Get(url)
	if err != nil {
		log.Println(err)
		return false

	}

	return resp.StatusCode == http.StatusOK
}
