package bodkins

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"

	"github.com/keithpaterson/resweave-utils/header"
	"github.com/keithpaterson/resweave-utils/mocks"
	"github.com/keithpaterson/resweave-utils/request"
	"github.com/keithpaterson/resweave-utils/response"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"go.uber.org/mock/gomock"
	"go.uber.org/zap"
)

const (
	host     = "localhost"
	port     = 8080
	testName = "Test Bodkin"
)

func composeURI() string {
	return fmt.Sprintf("http://%s:%d/bodkins", host, port)
}

func newBodkin(id int, name string) Bodkin {
	return Bodkin{ID: id, Name: name}
}

var _ = Describe("Bodkins", func() {
	var (
		br *BodkinResource

		recorder *httptest.ResponseRecorder
		writer   response.Writer
		ctx      context.Context
	)
	BeforeEach(func() {
		br = newBodkinResource()
		br.SetLogger(zap.NewNop().Sugar(), false)

		recorder = httptest.NewRecorder()
		writer = response.NewWriter(recorder)
		ctx = context.TODO()
	})
	Describe("Create", func() {
		It("should report an error if the input data is invalid", func() {
			// Arrange
			uri := composeURI()
			req, err := request.NewPostRequest(uri, request.WithCustomBody([]byte("not valid json"), header.MimeTypeJson))
			Expect(err).ToNot(HaveOccurred())

			// Act
			br.Create(ctx, writer, req)

			// Assert
			resp := recorder.Result()
			defer resp.Body.Close()

			// we expect the body to contain a service error
			var bodkin Bodkin
			svcErr := response.ParseResponseJsonData(resp, http.StatusOK, &bodkin)

			Expect(resp.StatusCode).To(Equal(http.StatusBadRequest))
			Expect(svcErr).To(MatchError(response.SvcErrorReadRequestFailed))
		})
		It("should report an error if request body cannot be read", func() {
			// Arrange
			uri := composeURI()
			req, err := request.NewPostRequest(uri, request.WithCustomBody([]byte("not valid json"), header.MimeTypeJson))
			Expect(err).ToNot(HaveOccurred())

			// force the body read to induce an error.
			ctrl := gomock.NewController(GinkgoT())
			defer ctrl.Finish()
			mockReader := mocks.NewMockReadCloser(ctrl)
			mockReader.EXPECT().Read(gomock.Any()).Times(1).Return(0, errors.New("irreconcilable differences"))

			req.Body = mockReader

			// Act
			br.Create(ctx, writer, req)

			// Assert
			resp := recorder.Result()
			defer resp.Body.Close()

			// we expect the body to contain a service error
			var bodkin Bodkin
			svcErr := response.ParseResponseJsonData(resp, http.StatusOK, &bodkin)

			Expect(resp.StatusCode).To(Equal(http.StatusBadRequest))
			Expect(svcErr).To(MatchError(response.SvcErrorReadRequestFailed))
		})
		It("should not respond when the response body could not be written", func() {
			// Arrange
			uri := composeURI()

			reqChronicle := Bodkin{Name: testName}
			req, err := request.NewPostRequest(uri, request.WithJsonBody(reqChronicle))
			Expect(err).ToNot(HaveOccurred())

			ctrl := gomock.NewController(GinkgoT())
			defer ctrl.Finish()
			mockWriter := mocks.NewMockResponseWriter(ctrl)
			// we end up calling WriteHeader twice; the real implementation will only actually write one though
			// (which isn't easy to mock)
			mockWriter.EXPECT().WriteHeader(http.StatusOK).Times(1)
			mockWriter.EXPECT().WriteHeader(http.StatusInternalServerError).Times(1)
			// expect two writes for this test: 1 the initial data, 2: an error message.  Fail both.
			mockWriter.EXPECT().Write(gomock.Any()).Times(2).Return(0, fmt.Errorf("irreconcilable differences"))

			writer = response.NewWriter(mockWriter)

			// Act && Assert
			br.Create(ctx, writer, req)
		})
		It("should be possible to create a bodkin", func() {
			// Arrange
			uri := composeURI()
			reqChronicle := Bodkin{Name: testName}

			req, err := request.NewPostRequest(uri, request.WithJsonBody(reqChronicle))
			Expect(err).ToNot(HaveOccurred())

			// Act
			br.Create(ctx, writer, req)

			// Assert
			resp := recorder.Result()
			defer resp.Body.Close()

			// we expect the body to contain a bodkin
			var respBodkin Bodkin
			svcErr := response.ParseResponseJsonData(resp, http.StatusOK, &respBodkin)

			Expect(svcErr).ToNot(HaveOccurred())
			Expect(resp.StatusCode).To(Equal(http.StatusOK))
			Expect(respBodkin.Name).To(Equal(reqChronicle.Name))
			Expect(respBodkin.ID).ToNot(BeNil())
		})
		It("should ignore ID in the request", func() {
			// Arrange
			uri := composeURI()
			id := 999
			reqChronicle := Bodkin{ID: id, Name: testName}

			req, err := request.NewPostRequest(uri, request.WithJsonBody(reqChronicle))
			Expect(err).ToNot(HaveOccurred())

			// Act
			br.Create(ctx, writer, req)

			// Assert
			resp := recorder.Result()
			defer resp.Body.Close()

			// we expect the body to contain a bodkin
			var respBodkin Bodkin
			svcErr := response.ParseResponseJsonData(resp, http.StatusOK, &respBodkin)

			Expect(svcErr).ToNot(HaveOccurred())
			Expect(resp.StatusCode).To(Equal(http.StatusOK))
			Expect(respBodkin.Name).To(Equal(reqChronicle.Name))
			Expect(respBodkin.ID).ToNot(BeNil())
			Expect(respBodkin.ID).ToNot(Equal(id))
		})
	})

	Describe("List", Ordered, func() {
		It("should not respond when the response body could not be written", func() {
			// Arrange
			uri := composeURI()
			req, err := request.NewGetRequest(uri)
			Expect(err).ToNot(HaveOccurred())

			ctrl := gomock.NewController(GinkgoT())
			defer ctrl.Finish()
			mockWriter := mocks.NewMockResponseWriter(ctrl)
			// we end up calling WriteHeader twice; the real implementation will only actually write one though
			// (which isn't easy to mock)
			mockWriter.EXPECT().WriteHeader(http.StatusOK).Times(1)
			mockWriter.EXPECT().WriteHeader(http.StatusInternalServerError).Times(1)
			// expect two writes for this test: 1 the initial data, 2: an error message.  Fail both.
			mockWriter.EXPECT().Write(gomock.Any()).Times(2).Return(0, fmt.Errorf("irreconcilable differences"))

			writer = response.NewWriter(mockWriter)

			// Act && Assert
			br.List(ctx, writer, req)
		})
		It("should be possible to list bodkins", func() {
			// Arrange
			uri := composeURI()
			req, err := request.NewGetRequest(uri)
			Expect(err).ToNot(HaveOccurred())

			names := []string{"One", "Two", "Three"}
			for index, name := range names {
				br.bodkins = append(br.bodkins, newBodkin(index, name))
			}

			// Act
			br.List(ctx, writer, req)

			// Assert
			resp := recorder.Result()
			defer resp.Body.Close()

			// we expect the body to contain bodkins
			var respBodkin []Bodkin
			svcErr := response.ParseResponseJsonData(resp, http.StatusOK, &respBodkin)

			Expect(svcErr).ToNot(HaveOccurred())
			Expect(resp.StatusCode).To(Equal(http.StatusOK))
			Expect(respBodkin).To(Equal(br.bodkins))
		})
	})
})
