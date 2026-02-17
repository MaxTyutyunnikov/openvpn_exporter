// Copyright 2017 Kumina, https://kumina.nl/
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package exporters

import (
	"strings"
	"testing"

	"github.com/prometheus/client_golang/prometheus"
	dto "github.com/prometheus/client_model/go"
)

func TestNewOpenVPNExporter(t *testing.T) {
	exporter, err := NewOpenVPNExporter([]string{"examples/client.status"}, false)
	if err != nil {
		t.Fatalf("Failed to create exporter: %v", err)
	}
	if exporter == nil {
		t.Fatal("Exporter should not be nil")
	}
	if len(exporter.statusPaths) != 1 {
		t.Errorf("Expected 1 status path, got %d", len(exporter.statusPaths))
	}
}

func TestNewOpenVPNExporter_IgnoreIndividuals(t *testing.T) {
	exporter, err := NewOpenVPNExporter([]string{"examples/server2.status"}, true)
	if err != nil {
		t.Fatalf("Failed to create exporter: %v", err)
	}
	if exporter == nil {
		t.Fatal("Exporter should not be nil")
	}
}

func TestCollectClientStatusFromReader(t *testing.T) {
	exporter, err := NewOpenVPNExporter([]string{}, false)
	if err != nil {
		t.Fatalf("Failed to create exporter: %v", err)
	}

	clientStatus := `OpenVPN STATISTICS
Updated,Thu Apr  5 10:59:09 2018
TUN/TAP read bytes,153789941
TUN/TAP write bytes,308764078
TCP/UDP read bytes,292806201
TCP/UDP write bytes,197558969
Auth read bytes,308854782
pre-compress bytes,45388190
post-compress bytes,45446864
pre-decompress bytes,162596168
post-decompress bytes,216965355
END
`

	ch := make(chan prometheus.Metric, 100)
	err = exporter.collectStatusFromReader("test", strings.NewReader(clientStatus), ch)
	if err != nil {
		t.Fatalf("collectStatusFromReader failed: %v", err)
	}
	close(ch)

	metrics := collectMetrics(ch)
	if len(metrics) == 0 {
		t.Error("Expected some metrics, got none")
	}
}

func TestCollectServerStatusFromReader_v2(t *testing.T) {
	exporter, err := NewOpenVPNExporter([]string{}, false)
	if err != nil {
		t.Fatalf("Failed to create exporter: %v", err)
	}

	serverStatusV2 := `TITLE,OpenVPN 2.4.0 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH] [IPv6] built on Mar 21 2017
TIME,1490089154,Wed Apr  5 10:59:14 2017
HEADER,CLIENT_LIST,Common Name,Real Address,Virtual Address,Connected Since (time_t),Username,Session ID,Bytes Received,Bytes Sent
CLIENT_LIST,client1,192.168.1.100:50000,10.8.0.2,1490089000,client1,0,1000,2000
HEADER,ROUTING_TABLE,Common Name,Real Address,Virtual Address,Last Ref (time_t)
ROUTING_TABLE,client1,192.168.1.100:50000,10.8.0.2,1490089100
GLOBAL_STATS,Max bcast/mcast queue length,1
END
`

	ch := make(chan prometheus.Metric, 100)
	err = exporter.collectStatusFromReader("test", strings.NewReader(serverStatusV2), ch)
	if err != nil {
		t.Fatalf("collectStatusFromReader failed: %v", err)
	}
	close(ch)

	metrics := collectMetrics(ch)
	if len(metrics) == 0 {
		t.Error("Expected some metrics, got none")
	}
}

func TestCollectServerStatusFromReader_v3(t *testing.T) {
	exporter, err := NewOpenVPNExporter([]string{}, false)
	if err != nil {
		t.Fatalf("Failed to create exporter: %v", err)
	}

	serverStatusV3 := `TITLE	OpenVPN 2.4.4 x86_64-pc-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH] [IPv6] built on Mar 21 2018
TIME	1522929554	Wed Apr  5 10:59:14 2018
HEADER	CLIENT_LIST	Common Name	Real Address	Virtual Address	Connected Since (time_t)	Username	Session ID	Bytes Received	Bytes Sent
CLIENT_LIST	client2	192.168.1.101:50001	10.8.0.3	1522929400	client2	0	3000	4000
HEADER	ROUTING_TABLE	Common Name	Real Address	Virtual Address	Last Ref (time_t)
ROUTING_TABLE	client2	192.168.1.101:50001	10.8.0.3	1522929500
GLOBAL_STATS	Max bcast/mcast queue length	1
END
`

	ch := make(chan prometheus.Metric, 100)
	err = exporter.collectStatusFromReader("test", strings.NewReader(serverStatusV3), ch)
	if err != nil {
		t.Fatalf("collectStatusFromReader failed: %v", err)
	}
	close(ch)

	metrics := collectMetrics(ch)
	if len(metrics) == 0 {
		t.Error("Expected some metrics, got none")
	}
}

func TestParseUpdatedTime(t *testing.T) {
	tests := []struct {
		input    string
		expected float64
		hasError bool
	}{
		{"Thu Apr  5 10:59:09 2018", 1522925949, false},
		{"2018-04-05 10:59:09", 1522925949, false},
		{"invalid", 0, true},
	}

	for _, tt := range tests {
		result, err := parseUpdatedTime(tt.input)
		if tt.hasError && err == nil {
			t.Errorf("Expected error for input %q, got nil", tt.input)
		}
		if !tt.hasError && err != nil {
			t.Errorf("Unexpected error for input %q: %v", tt.input, err)
		}
		if !tt.hasError && int(result) != int(tt.expected) {
			t.Errorf("For input %q: expected %f, got %f", tt.input, tt.expected, result)
		}
	}
}

func TestContains(t *testing.T) {
	slice := []string{"a", "b", "c"}
	if !contains(slice, "b") {
		t.Error("Expected slice to contain 'b'")
	}
	if contains(slice, "d") {
		t.Error("Expected slice to not contain 'd'")
	}
}

func TestSubslice(t *testing.T) {
	main := []string{"a", "b", "c", "d"}
	sub := []string{"b", "c"}
	if !subslice(sub, main) {
		t.Error("Expected sub to be a subslice of main")
	}

	sub2 := []string{"b", "e"}
	if subslice(sub2, main) {
		t.Error("Expected sub2 to not be a subslice of main")
	}
}

// Helper function to collect metrics from channel
func collectMetrics(ch <-chan prometheus.Metric) []*dto.Metric {
	var metrics []*dto.Metric
	for m := range ch {
		dtoMetric := &dto.Metric{}
		if err := m.Write(dtoMetric); err == nil {
			metrics = append(metrics, dtoMetric)
		}
	}
	return metrics
}
