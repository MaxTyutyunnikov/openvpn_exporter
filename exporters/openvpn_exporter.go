package exporters

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/prometheus/client_golang/prometheus"
)

const timeFormat = "Mon Jan  2 15:04:05 2006"

type OpenvpnServerHeader struct {
	LabelColumns []string
	Metrics      []OpenvpnServerHeaderField
}

type OpenvpnServerHeaderField struct {
	Column    string
	Desc      *prometheus.Desc
	ValueType prometheus.ValueType
}

type OpenVPNExporter struct {
	statusPaths                 []string
	openvpnUpDesc               *prometheus.Desc
	openvpnStatusUpdateTimeDesc *prometheus.Desc
	openvpnConnectedClientsDesc *prometheus.Desc
	openvpnMaxQueueLenghtDesc   *prometheus.Desc
	openvpnClientDescs          map[string]*prometheus.Desc
	openvpnServerHeaders        map[string]OpenvpnServerHeader
	openvpnServer247Headers     map[string]OpenvpnServerHeader
}

func NewOpenVPNExporter(statusPaths []string, ignoreIndividuals bool) (*OpenVPNExporter, error) {
	// Metrics exported both for client and server statistics.
	openvpnUpDesc := prometheus.NewDesc(
		prometheus.BuildFQName("openvpn", "", "up"),
		"Whether scraping OpenVPN's metrics was successful.",
		[]string{"status_path"}, nil)
	openvpnStatusUpdateTimeDesc := prometheus.NewDesc(
		prometheus.BuildFQName("openvpn", "", "status_update_time_seconds"),
		"UNIX timestamp at which the OpenVPN statistics were updated.",
		[]string{"status_path"}, nil)

	// Metrics specific to OpenVPN servers.
	openvpnConnectedClientsDesc := prometheus.NewDesc(
		prometheus.BuildFQName("openvpn", "", "server_connected_clients"),
		"Number Of Connected Clients",
		[]string{"status_path"}, nil)
	openvpnMaxQueueLenghtDesc := prometheus.NewDesc(
		prometheus.BuildFQName("openvpn", "", "server_max_queue_length"),
		"Max queue length",
		[]string{"status_path"}, nil)

	// Metrics specific to OpenVPN clients.
	openvpnClientDescs := map[string]*prometheus.Desc{
		"TUN/TAP read bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "tun_tap_read_bytes_total"),
			"Total amount of TUN/TAP traffic read, in bytes.",
			[]string{"status_path"}, nil),
		"TUN/TAP write bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "tun_tap_write_bytes_total"),
			"Total amount of TUN/TAP traffic written, in bytes.",
			[]string{"status_path"}, nil),
		"TCP/UDP read bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "tcp_udp_read_bytes_total"),
			"Total amount of TCP/UDP traffic read, in bytes.",
			[]string{"status_path"}, nil),
		"TCP/UDP write bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "tcp_udp_write_bytes_total"),
			"Total amount of TCP/UDP traffic written, in bytes.",
			[]string{"status_path"}, nil),
		"Auth read bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "auth_read_bytes_total"),
			"Total amount of authentication traffic read, in bytes.",
			[]string{"status_path"}, nil),
		"pre-compress bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "pre_compress_bytes_total"),
			"Total amount of data before compression, in bytes.",
			[]string{"status_path"}, nil),
		"post-compress bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "post_compress_bytes_total"),
			"Total amount of data after compression, in bytes.",
			[]string{"status_path"}, nil),
		"pre-decompress bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "pre_decompress_bytes_total"),
			"Total amount of data before decompression, in bytes.",
			[]string{"status_path"}, nil),
		"post-decompress bytes": prometheus.NewDesc(
			prometheus.BuildFQName("openvpn", "client", "post_decompress_bytes_total"),
			"Total amount of data after decompression, in bytes.",
			[]string{"status_path"}, nil),
	}

	var serverHeaderClientLabels []string
	var serverHeader247ClientLabels []string
	var serverHeaderClientLabelColumns []string
	var serverHeader247ClientLabelColumns []string
	var serverHeaderRoutingLabels []string
	var serverHeaderRoutingLabelColumns []string
	if ignoreIndividuals {
		serverHeaderClientLabels = []string{"status_path", "common_name"}
		serverHeaderClientLabelColumns = []string{"Common Name"}
		serverHeaderRoutingLabels = []string{"status_path", "common_name"}
		serverHeaderRoutingLabelColumns = []string{"Common Name"}
	} else {
		serverHeaderClientLabels = []string{"status_path", "common_name", "connection_time", "real_address", "virtual_address", "username"}
		serverHeader247ClientLabels = []string{"status_path", "common_name", "real_address", "connection_time"}
		serverHeaderClientLabelColumns = []string{"Common Name", "Connected Since (time_t)", "Real Address", "Virtual Address", "Username"}
		serverHeader247ClientLabelColumns = []string{"Common Name", "Real Address", "Connected Since"}
		serverHeaderRoutingLabels = []string{"status_path", "common_name", "real_address", "virtual_address"}
		serverHeaderRoutingLabelColumns = []string{"Common Name", "Real Address", "Virtual Address"}
	}

	openvpnServerHeaders := map[string]OpenvpnServerHeader{
		"CLIENT_LIST": {
			LabelColumns: serverHeaderClientLabelColumns,
			Metrics: []OpenvpnServerHeaderField{
				{
					Column: "Bytes Received",
					Desc: prometheus.NewDesc(
						prometheus.BuildFQName("openvpn", "server", "client_received_bytes_total"),
						"Amount of data received over a connection on the VPN server, in bytes.",
						serverHeaderClientLabels, nil),
					ValueType: prometheus.CounterValue,
				},
				{
					Column: "Bytes Sent",
					Desc: prometheus.NewDesc(
						prometheus.BuildFQName("openvpn", "server", "client_sent_bytes_total"),
						"Amount of data sent over a connection on the VPN server, in bytes.",
						serverHeaderClientLabels, nil),
					ValueType: prometheus.CounterValue,
				},
			},
		},
		"ROUTING_TABLE": {
			LabelColumns: serverHeaderRoutingLabelColumns,
			Metrics: []OpenvpnServerHeaderField{
				{
					Column: "Last Ref (time_t)",
					Desc: prometheus.NewDesc(
						prometheus.BuildFQName("openvpn", "server", "route_last_reference_time_seconds"),
						"Time at which a route was last referenced, in seconds.",
						serverHeaderRoutingLabels, nil),
					ValueType: prometheus.GaugeValue,
				},
			},
		},
	}

	openvpnServer247Headers := map[string]OpenvpnServerHeader{
		"CLIENT_LIST": {
			LabelColumns: serverHeader247ClientLabelColumns,
			Metrics: []OpenvpnServerHeaderField{
				{
					Column: "Bytes Received",
					Desc: prometheus.NewDesc(
						prometheus.BuildFQName("openvpn", "server", "client_received_bytes_total"),
						"Amount of data received over a connection on the VPN server, in bytes.",
						serverHeader247ClientLabels, nil),
					ValueType: prometheus.CounterValue,
				},
				{
					Column: "Bytes Sent",
					Desc: prometheus.NewDesc(
						prometheus.BuildFQName("openvpn", "server", "client_sent_bytes_total"),
						"Amount of data sent over a connection on the VPN server, in bytes.",
						serverHeader247ClientLabels, nil),
					ValueType: prometheus.CounterValue,
				},
			},
		},
		"ROUTING_TABLE": {
			LabelColumns: serverHeaderRoutingLabelColumns,
			Metrics: []OpenvpnServerHeaderField{
				{
					Column: "Last Ref",
					Desc: prometheus.NewDesc(
						prometheus.BuildFQName("openvpn", "server", "route_last_reference_time_seconds"),
						"Time at which a route was last referenced, in seconds.",
						serverHeaderRoutingLabels, nil),
					ValueType: prometheus.GaugeValue,
				},
			},
		},
	}

	return &OpenVPNExporter{
		statusPaths:                 statusPaths,
		openvpnUpDesc:               openvpnUpDesc,
		openvpnStatusUpdateTimeDesc: openvpnStatusUpdateTimeDesc,
		openvpnConnectedClientsDesc: openvpnConnectedClientsDesc,
		openvpnMaxQueueLenghtDesc:   openvpnMaxQueueLenghtDesc,
		openvpnClientDescs:          openvpnClientDescs,
		openvpnServerHeaders:        openvpnServerHeaders,
		openvpnServer247Headers:     openvpnServer247Headers,
	}, nil
}

// Converts OpenVPN status information into Prometheus metrics. This
// function automatically detects whether the file contains server or
// client metrics. For server metrics, it also distinguishes between the
// version 2 and 3 file formats.
func (e *OpenVPNExporter) collectStatusFromReader(statusPath string, file io.Reader, ch chan<- prometheus.Metric) error {
	reader := bufio.NewReader(file)
	buf, _ := reader.Peek(20)
	if bytes.HasPrefix(buf, []byte("TITLE,")) {
		// Server statistics, using format version 2.
		return e.collectServerStatusFromReader(statusPath, reader, ch, ",")
	} else if bytes.HasPrefix(buf, []byte("TITLE\t")) {
		// Server statistics, using format version 3. The only
		// difference compared to version 2 is that it uses tabs
		// instead of spaces.
		return e.collectServerStatusFromReader(statusPath, reader, ch, "\t")
	} else if bytes.HasPrefix(buf, []byte("OpenVPN CLIENT LIST")) {
		// Ubuntu 20.20 Version 2.4.7
		return e.collect247ServerStatusFromReader(statusPath, reader, ch)
	} else if bytes.HasPrefix(buf, []byte("OpenVPN STATISTICS")) {
		// Client statistics.
		return e.collectClientStatusFromReader(statusPath, reader, ch)
	} else {
		return fmt.Errorf("unexpected file contents: %q", buf)
	}
}

func (e *OpenVPNExporter) collect247ServerStatusFromReader(statusPath string, file io.Reader, ch chan<- prometheus.Metric) error {
	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanLines)
	// counter of connected client
	numberConnectedClient := 0
	headersFound := map[string][]string{}
	recordedMetrics := map[OpenvpnServerHeaderField][]string{}

	for scanner.Scan() {
		fields := strings.Split(scanner.Text(), ",")
		if len(fields) == 5 {
			// A Client line, if it not the header it will be processed
			if fields[0] != "Common Name" {
				numberConnectedClient++
				dublicate, err := export247Metrics(e, "CLIENT_LIST", headersFound, fields, recordedMetrics, statusPath, ch)
				if err != nil {
					return err
				}
				if dublicate {
					numberConnectedClient--
				}
			} else {
				headersFound["CLIENT_LIST"] = fields
			}

		} else if len(fields) == 4 {
			// A Routing Table line, if it not the header it will be processed
			if fields[0] != "Virtual Address" {
				_, err := export247Metrics(e, "ROUTING_TABLE", headersFound, fields, recordedMetrics, statusPath, ch)
				if err != nil {
					return err
				}
			} else {
				headersFound["ROUTING_TABLE"] = fields
			}

		} else if fields[0] == "Updated" {
			// Time at which the statistics were updated.
			timeStartStats, err := time.Parse(timeFormat, fields[1])
			if err != nil {
				return err
			}
			ch <- prometheus.MustNewConstMetric(
				e.openvpnStatusUpdateTimeDesc,
				prometheus.GaugeValue,
				float64(timeStartStats.Unix()),
				statusPath)

		} else if fields[0] == "Max bcast/mcast queue length" {
			queueLength, err := strconv.ParseFloat(fields[1], 64)
			if err != nil {
				return err
			}
			ch <- prometheus.MustNewConstMetric(
				e.openvpnMaxQueueLenghtDesc,
				prometheus.GaugeValue,
				queueLength,
				statusPath)
		}

	}
	// add the number of connected client
	ch <- prometheus.MustNewConstMetric(
		e.openvpnConnectedClientsDesc,
		prometheus.GaugeValue,
		float64(numberConnectedClient),
		statusPath)
	return scanner.Err()
}

func export247Metrics(e *OpenVPNExporter, tableName string, headersFound map[string][]string, fields []string, recordedMetrics map[OpenvpnServerHeaderField][]string, statusPath string, ch chan<- prometheus.Metric) (bool, error) {
	header := e.openvpnServer247Headers[tableName]
	columnNames, ok := headersFound[tableName]
	dublicate := false
	if !ok {
		return false, fmt.Errorf("%s should be preceded after the HEADERS", fields[0])
	}
	if len(fields) > len(columnNames) {
		return false, fmt.Errorf("HEADER for %s describes a different number of columns", fields[0])
	}

	// Store entry values in a map indexed by column name.
	columnValues := map[string]string{}
	for _, column := range header.LabelColumns {
		columnValues[column] = ""
	}
	for i, column := range columnNames {
		columnValues[column] = fields[i]
	}
	// Extract columns that should act as entry labels.
	labels := []string{statusPath}
	for _, column := range header.LabelColumns {
		labels = append(labels, columnValues[column])
	}
	// Export relevant columns as individual metrics.
	for _, metric := range header.Metrics {
		if columnValue, ok := columnValues[metric.Column]; ok {
			if l, _ := recordedMetrics[metric]; !subslice(labels, l) {
				value, err := convertValue(columnValue)
				if err != nil {
					return false, err
				}
				ch <- prometheus.MustNewConstMetric(
					metric.Desc,
					metric.ValueType,
					value,
					labels...)
				recordedMetrics[metric] = append(recordedMetrics[metric], labels...)
			} else {
				dublicate = true
				log.Printf("Metric entry with same labels: %s, %s", metric.Column, labels)
			}
		}
	}

	return dublicate, nil
}

func convertValue(value string) (float64, error) {
	var err error
	var timeValue time.Time
	var floatValue float64

	floatValue, err = strconv.ParseFloat(value, 64)
	if err == nil {
		return floatValue, nil
	}
	timeValue, err = time.Parse(timeFormat, value)
	if err == nil {
		return float64(timeValue.Unix()), nil
	}

	return 0.0, err
}

// Converts OpenVPN server status information into Prometheus metrics.
func (e *OpenVPNExporter) collectServerStatusFromReader(statusPath string, file io.Reader, ch chan<- prometheus.Metric, separator string) error {
	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanLines)
	headersFound := map[string][]string{}
	// counter of connected client
	numberConnectedClient := 0

	recordedMetrics := map[OpenvpnServerHeaderField][]string{}

	for scanner.Scan() {
		fields := strings.Split(scanner.Text(), separator)
		if fields[0] == "END" && len(fields) == 1 {
			// Stats footer.
		} else if fields[0] == "GLOBAL_STATS" {
			// Global server statistics.
		} else if fields[0] == "HEADER" && len(fields) > 2 {
			// Column names for CLIENT_LIST and ROUTING_TABLE.
			headersFound[fields[1]] = fields[2:]
		} else if fields[0] == "TIME" && len(fields) == 3 {
			// Time at which the statistics were updated.
			timeStartStats, err := strconv.ParseFloat(fields[2], 64)
			if err != nil {
				return err
			}
			ch <- prometheus.MustNewConstMetric(
				e.openvpnStatusUpdateTimeDesc,
				prometheus.GaugeValue,
				timeStartStats,
				statusPath)
		} else if fields[0] == "TITLE" && len(fields) == 2 {
			// OpenVPN version number.
		} else if header, ok := e.openvpnServerHeaders[fields[0]]; ok {
			if fields[0] == "CLIENT_LIST" {
				numberConnectedClient++
			}
			// Entry that depends on a preceding HEADERS directive.
			columnNames, ok := headersFound[fields[0]]
			if !ok {
				return fmt.Errorf("%s should be preceded by HEADERS", fields[0])
			}
			if len(fields) != len(columnNames)+1 {
				return fmt.Errorf("HEADER for %s describes a different number of columns", fields[0])
			}

			// Store entry values in a map indexed by column name.
			columnValues := map[string]string{}
			for _, column := range header.LabelColumns {
				columnValues[column] = ""
			}
			for i, column := range columnNames {
				columnValues[column] = fields[i+1]
			}

			// Extract columns that should act as entry labels.
			labels := []string{statusPath}
			for _, column := range header.LabelColumns {
				labels = append(labels, columnValues[column])
			}

			// Export relevant columns as individual metrics.
			for _, metric := range header.Metrics {
				if columnValue, ok := columnValues[metric.Column]; ok {
					if l, _ := recordedMetrics[metric]; !subslice(labels, l) {
						value, err := strconv.ParseFloat(columnValue, 64)
						if err != nil {
							return err
						}
						ch <- prometheus.MustNewConstMetric(
							metric.Desc,
							metric.ValueType,
							value,
							labels...)
						recordedMetrics[metric] = append(recordedMetrics[metric], labels...)
					} else {
						log.Printf("Metric entry with same labels: %s, %s", metric.Column, labels)
					}
				}
			}
		} else {
			return fmt.Errorf("unsupported key: %q", fields[0])
		}
	}
	// add the number of connected client
	ch <- prometheus.MustNewConstMetric(
		e.openvpnConnectedClientsDesc,
		prometheus.GaugeValue,
		float64(numberConnectedClient),
		statusPath)
	return scanner.Err()
}

// Does slice contain string
func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

// Is a sub-slice of slice
func subslice(sub []string, main []string) bool {
	if len(sub) > len(main) {
		return false
	}
	for _, s := range sub {
		if !contains(main, s) {
			return false
		}
	}
	return true
}

// Converts OpenVPN client status information into Prometheus metrics.
func (e *OpenVPNExporter) collectClientStatusFromReader(statusPath string, file io.Reader, ch chan<- prometheus.Metric) error {
	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanLines)
	for scanner.Scan() {
		fields := strings.Split(scanner.Text(), ",")
		if fields[0] == "END" && len(fields) == 1 {
			// Stats footer.
		} else if fields[0] == "OpenVPN STATISTICS" && len(fields) == 1 {
			// Stats header.
		} else if fields[0] == "Updated" && len(fields) == 2 {
			// Time at which the statistics were updated.
			location, _ := time.LoadLocation("Local")
			timeParser, err := time.ParseInLocation("Mon Jan 2 15:04:05 2006", fields[1], location)
			if err != nil {
				return err
			}
			ch <- prometheus.MustNewConstMetric(
				e.openvpnStatusUpdateTimeDesc,
				prometheus.GaugeValue,
				float64(timeParser.Unix()),
				statusPath)
		} else if desc, ok := e.openvpnClientDescs[fields[0]]; ok && len(fields) == 2 {
			// Traffic counters.
			value, err := strconv.ParseFloat(fields[1], 64)
			if err != nil {
				return err
			}
			ch <- prometheus.MustNewConstMetric(
				desc,
				prometheus.CounterValue,
				value,
				statusPath)
		} else {
			return fmt.Errorf("unsupported key: %q", fields[0])
		}
	}
	return scanner.Err()
}

func (e *OpenVPNExporter) collectStatusFromFile(statusPath string, ch chan<- prometheus.Metric) error {
	conn, err := os.Open(statusPath)
	defer conn.Close()
	if err != nil {
		return err
	}
	return e.collectStatusFromReader(statusPath, conn, ch)
}

func (e *OpenVPNExporter) Describe(ch chan<- *prometheus.Desc) {
	ch <- e.openvpnUpDesc
}

func (e *OpenVPNExporter) Collect(ch chan<- prometheus.Metric) {
	for _, statusPath := range e.statusPaths {
		err := e.collectStatusFromFile(statusPath, ch)
		if err == nil {
			ch <- prometheus.MustNewConstMetric(
				e.openvpnUpDesc,
				prometheus.GaugeValue,
				1.0,
				statusPath)
		} else {
			log.Printf("Failed to scrape showq socket: %s", err)
			ch <- prometheus.MustNewConstMetric(
				e.openvpnUpDesc,
				prometheus.GaugeValue,
				0.0,
				statusPath)
		}
	}
}
