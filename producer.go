package main

import (
	"bytes"
	"fmt"
	"log"
	"net/http"

	"github.com/RashadAnsari/fluentd-protobuf-proxy-example/proto"
	gproto "google.golang.org/protobuf/proto"
)

func main() {
	sayHello := proto.SayHello{
		Name: "Rashad",
	}

	data, err := gproto.Marshal(&sayHello)
	if err != nil {
		log.Fatalf("failed to marshal proto message: %s", err.Error())
	}

	url := "http://127.0.0.1:8080/hello_world?msgtype=hello_world.SayHello&batch=false"

	req, err := http.NewRequest("POST", url, bytes.NewBuffer(data))
	if err != nil {
		log.Fatalf("failed to create fluentd request: %s", err.Error())
	}

	req.Header.Set("Content-Type", "application/octet-stream")

	client := http.Client{}

	resp, err := client.Do(req)
	if err != nil {
		log.Fatalf("failed to send request to fluentd: %s", err.Error())
	}

	_ = resp.Body.Close()

	if resp.StatusCode == http.StatusOK {
		fmt.Println("OK!")
	} else {
		fmt.Println("Fail!")
	}
}
