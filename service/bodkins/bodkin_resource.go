package bodkins

import (
	"context"
	"net/http"
	"sync"

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
	resweave.APIResource

	bodkins []Bodkin
	nextID  int
	mtx     sync.Mutex
}

func AddResource(server resweave.Server) error {
	res := newResource(resourceName)
	res.SetID(resweave.NumericID)
	return server.AddResource(res)
}

func newResource(name resweave.ResourceName) *BodkinResource {
	res := &BodkinResource{
		APIResource: resweave.NewAPI(name),
		bodkins:     make([]Bodkin, 0),
	}
	res.SetList(res.list)
	res.SetCreate(res.create)
	return res
}

func (b *BodkinResource) list(_ context.Context, w http.ResponseWriter, req *http.Request) {
	// skip validations (are there any?)

	writer := response.NewWriter(w)

	writer.WriteJsonResponse(http.StatusOK, b.bodkins)
}

func (b *BodkinResource) create(_ context.Context, w http.ResponseWriter, req *http.Request) {
	// skip validations for now

	writer := response.NewWriter(w)

	var data Bodkin
	err := rw.UnmarshalJson(req.Body, &data)
	if err != nil {
		writer.WriteErrorResponse(http.StatusBadRequest, response.SvcErrorReadRequestFailed)
	}

	b.mtx.Lock()
	defer b.mtx.Unlock()

	// ignore id in create and set it to the "next" one
	data.Id = b.nextID
	b.nextID++

	b.bodkins = append(b.bodkins, data)
	writer.WriteJsonResponse(http.StatusOK, data)
}
