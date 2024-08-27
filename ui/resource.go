package ui

import (
	"errors"

	"github.com/agilitree/resweave"
	"github.com/mortedecai/go-go-gadgets/env"
)

var (
	ErrNilServer = errors.New("server was nil")
)

func AddResource(server resweave.Server) error {
	if server == nil {
		return ErrNilServer
	}
	// Full parameterization to be done in https://github.com/orgs/agilitree/projects/3/views/1?pane=issue&itemId=55165575
	// This was needed for debugging and left in due to that need; can be modified once configuration approach is determined.
	baseDir, _ := env.GetWithDefault("WEBKINS_UI_PATH", "html/")
	res := resweave.NewHTML("", baseDir)
	return server.AddResource(res)
}
