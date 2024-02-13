#!/usr/bin/haserl
<%
faceter_date=$(stat -c '%.10y' /usr/bin/faceter-camera)
faceter_version="$(faceter-camera -v) (${faceter_date})"
%>
