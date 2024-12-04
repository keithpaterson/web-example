package main

import (
	"errors"
	"fmt"
	"os"

	"github.com/mortedecai/resweave"
	"go.uber.org/zap"

	"webkins/service/bodkins"
	"webkins/ui"

	"github.com/keithpaterson/resweave-utils/logging"
)

type ResourceGenerator func(s resweave.Server) error

type ResourceGenerators []ResourceGenerator

var (
	// ErrorMissingServerOrLogger - error message returned during bad setup
	ErrorMissingServerOrLogger error = errors.New("missing server or logger")

	generators = ResourceGenerators{
		ui.AddResource,
		bodkins.AddResource,
	}
)

//go:generate mockgen -destination=../../mocks/resweave_mocks.go -package=mocks github.com/mortedecai/resweave Server
func main() {
	fmt.Printf("Starting server and logging")

	// Setup the logger
	logger, err := logging.RootLogger()
	if err != nil {
		fmt.Println("******** COULD NOT CREATE A LOGGER!!!!!!! ************")
		fmt.Println("\t", err)
		os.Exit(-1)
	}

	// Probably want to get the port from config
	server := resweave.NewServer(8080)

	// Setup and start the server
	err = setupServer(server, logger)

	if err != nil {
		fmt.Println("Server had a problem starting: ", err)
	}
}

func setupServer(server resweave.Server, logger *zap.SugaredLogger) error {
	if server == nil || logger == nil {
		return ErrorMissingServerOrLogger
	}

	// Setup each of the APIs/endpoints
	for _, generateResource := range generators {
		if err := generateResource(server); err != nil {
			// If we can't add the resource there's no sense continuing the application; it won't work.
			panic(err)
		}
	}

	// This sets the logger for all endpoints
	server.SetLogger(logger, true)

	// Start the server
	return server.Run()
}
