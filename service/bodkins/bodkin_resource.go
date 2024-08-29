package bodkins

import (
	"context"
	"fmt"
	"net/http"
	"sync"

	"github.com/keithpaterson/resweave-utils/resource"
	"github.com/keithpaterson/resweave-utils/response"
	"github.com/keithpaterson/resweave-utils/utility/rw"

	"github.com/agilitree/resweave"
)

const (
	resourceName = "bodkins"
)

type Bodkin struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
}

type BodkinResource struct {
	resweave.LogHolder

	bodkins []Bodkin
	nextID  int
	mtx     sync.Mutex
}

func AddResource(server resweave.Server) error {
	res := resource.NewResource(resourceName, newBodkinResource(resourceName))
	res.SetID(resweave.NumericID)
	return res.AddEasyResource(server)
}

func newBodkinResource(name resweave.ResourceName) *BodkinResource {
	res := &BodkinResource{
		LogHolder: resweave.NewLogholder(name.String(), nil),
		bodkins:   make([]Bodkin, 0),
	}
	return res
}

func (b *BodkinResource) List(_ context.Context, writer response.Writer, req *http.Request) {
	b.mtx.Lock()
	defer b.mtx.Unlock()

	if err := writer.WriteJsonResponse(http.StatusOK, b.bodkins); err != nil {
		b.Errorw("List", "response-write-error", fmt.Errorf("failed to write response body: %w", err))
	}
}

func (b *BodkinResource) Create(_ context.Context, writer response.Writer, req *http.Request) {
	var data Bodkin
	err := rw.UnmarshalJson(req.Body, &data)
	if err != nil {
		b.Errorw("Create", "body-error", fmt.Errorf("failed to parse request body: %w", err))
		writer.WriteErrorResponse(http.StatusBadRequest, response.SvcErrorReadRequestFailed)
	}

	b.mtx.Lock()
	defer b.mtx.Unlock()

	// ignore id in create and set it to the "next" one
	data.Id = b.nextID
	b.nextID++

	b.bodkins = append(b.bodkins, data)
	if err := writer.WriteJsonResponse(http.StatusOK, data); err != nil {
		b.Errorw("Create", "response-write-error", fmt.Errorf("failed to write response body: %w", err))
	}
}
