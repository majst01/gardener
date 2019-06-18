package vpc

//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//
// Code generated by Alibaba Cloud SDK Code Generator.
// Changes may cause incorrect behavior and will be lost if the code is regenerated.

import (
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk/requests"
	"github.com/aliyun/alibaba-cloud-sdk-go/sdk/responses"
)

// ModifyCustomerGatewayAttribute invokes the vpc.ModifyCustomerGatewayAttribute API synchronously
// api document: https://help.aliyun.com/api/vpc/modifycustomergatewayattribute.html
func (client *Client) ModifyCustomerGatewayAttribute(request *ModifyCustomerGatewayAttributeRequest) (response *ModifyCustomerGatewayAttributeResponse, err error) {
	response = CreateModifyCustomerGatewayAttributeResponse()
	err = client.DoAction(request, response)
	return
}

// ModifyCustomerGatewayAttributeWithChan invokes the vpc.ModifyCustomerGatewayAttribute API asynchronously
// api document: https://help.aliyun.com/api/vpc/modifycustomergatewayattribute.html
// asynchronous document: https://help.aliyun.com/document_detail/66220.html
func (client *Client) ModifyCustomerGatewayAttributeWithChan(request *ModifyCustomerGatewayAttributeRequest) (<-chan *ModifyCustomerGatewayAttributeResponse, <-chan error) {
	responseChan := make(chan *ModifyCustomerGatewayAttributeResponse, 1)
	errChan := make(chan error, 1)
	err := client.AddAsyncTask(func() {
		defer close(responseChan)
		defer close(errChan)
		response, err := client.ModifyCustomerGatewayAttribute(request)
		if err != nil {
			errChan <- err
		} else {
			responseChan <- response
		}
	})
	if err != nil {
		errChan <- err
		close(responseChan)
		close(errChan)
	}
	return responseChan, errChan
}

// ModifyCustomerGatewayAttributeWithCallback invokes the vpc.ModifyCustomerGatewayAttribute API asynchronously
// api document: https://help.aliyun.com/api/vpc/modifycustomergatewayattribute.html
// asynchronous document: https://help.aliyun.com/document_detail/66220.html
func (client *Client) ModifyCustomerGatewayAttributeWithCallback(request *ModifyCustomerGatewayAttributeRequest, callback func(response *ModifyCustomerGatewayAttributeResponse, err error)) <-chan int {
	result := make(chan int, 1)
	err := client.AddAsyncTask(func() {
		var response *ModifyCustomerGatewayAttributeResponse
		var err error
		defer close(result)
		response, err = client.ModifyCustomerGatewayAttribute(request)
		callback(response, err)
		result <- 1
	})
	if err != nil {
		defer close(result)
		callback(nil, err)
		result <- 0
	}
	return result
}

// ModifyCustomerGatewayAttributeRequest is the request struct for api ModifyCustomerGatewayAttribute
type ModifyCustomerGatewayAttributeRequest struct {
	*requests.RpcRequest
	ResourceOwnerId      requests.Integer `position:"Query" name:"ResourceOwnerId"`
	ResourceOwnerAccount string           `position:"Query" name:"ResourceOwnerAccount"`
	ClientToken          string           `position:"Query" name:"ClientToken"`
	OwnerAccount         string           `position:"Query" name:"OwnerAccount"`
	Name                 string           `position:"Query" name:"Name"`
	Description          string           `position:"Query" name:"Description"`
	OwnerId              requests.Integer `position:"Query" name:"OwnerId"`
	CustomerGatewayId    string           `position:"Query" name:"CustomerGatewayId"`
}

// ModifyCustomerGatewayAttributeResponse is the response struct for api ModifyCustomerGatewayAttribute
type ModifyCustomerGatewayAttributeResponse struct {
	*responses.BaseResponse
	RequestId         string `json:"RequestId" xml:"RequestId"`
	CustomerGatewayId string `json:"CustomerGatewayId" xml:"CustomerGatewayId"`
	IpAddress         string `json:"IpAddress" xml:"IpAddress"`
	Name              string `json:"Name" xml:"Name"`
	Description       string `json:"Description" xml:"Description"`
	CreateTime        int    `json:"CreateTime" xml:"CreateTime"`
}

// CreateModifyCustomerGatewayAttributeRequest creates a request to invoke ModifyCustomerGatewayAttribute API
func CreateModifyCustomerGatewayAttributeRequest() (request *ModifyCustomerGatewayAttributeRequest) {
	request = &ModifyCustomerGatewayAttributeRequest{
		RpcRequest: &requests.RpcRequest{},
	}
	request.InitWithApiInfo("Vpc", "2016-04-28", "ModifyCustomerGatewayAttribute", "vpc", "openAPI")
	return
}

// CreateModifyCustomerGatewayAttributeResponse creates a response to parse from ModifyCustomerGatewayAttribute response
func CreateModifyCustomerGatewayAttributeResponse() (response *ModifyCustomerGatewayAttributeResponse) {
	response = &ModifyCustomerGatewayAttributeResponse{
		BaseResponse: &responses.BaseResponse{},
	}
	return
}