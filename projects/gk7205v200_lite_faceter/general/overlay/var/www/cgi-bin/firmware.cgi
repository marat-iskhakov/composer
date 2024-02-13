#!/usr/bin/haserl
<%in p/common.cgi %>
<%in p/faceter.cgi %>

<%
page_title="Firmware"

url="https://cloud.faceter.cam/fw/opc/download/latest/version.txt" ;

if [ -n "$network_gateway" ]; then
        faceter_latest=$(curl -fs "$url" | grep $soc | awk -F ";" '{print $2,"("$3")"}')
else
        faceter_latest="<span class=\"text-danger\">- no access to Faceter server -</span>"
fi

fw_kernel="true"
fw_rootfs="true"

%>
<%in p/header.cgi %>

<div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4 mb-4">
  <div class="col">
    <h3>Version</h3>
      <dl class="list small">
      <dt>Installed Faceter</dt>
      <dd><%= $faceter_version %></dd>
      <dt>Latest Faceter</dt>
      <dd id="firmware-master-ver"><%= $faceter_latest %></dd>
    </dl>
  </div>
  <div class="col">
    <h3>Upgrade</h3>
    <% if [ -n "$network_gateway" ]; then %>
      <form action="firmware-update.cgi" method="post">
        <div><span style="display: none;"> <% field_checkbox "fw_kernel" "Upgrade kernel." %> </div>
        <div><span style="display: none;"> <% field_checkbox "fw_rootfs" "Upgrade rootfs." %> </div>
        <% field_checkbox "fw_reset" "Reset firmware." %>
        <% field_checkbox "fw_noreboot" "Do not reboot after upgrade." %>
        <% field_checkbox "fw_enforce" "Install even if matches the existing version." %>
        <% button_submit "Install update from Faceter server" "warning" %>
      </form>
    <% else %>
      <p class="alert alert-danger">Upgrading requires access to GitHub.</p>
    <% fi %>
  </div>
  <div class="col">
    <h3>Upload Kernel & RootFS</h3>
    <form action="firmware-upload-parts.cgi" method="post" enctype="multipart/form-data">
      <% field_file "parts_file" "Binary file" %>
      <% field_select "parts_type" "Type of the binary file" "kernel,rootfs" %>
      <p class="text-danger small">Destructive! Make sure you know what you are doing.</p>
      <% button_submit "Upload file" "danger" %>
    </form>
  </div>
</div>

<%in p/footer.cgi %>
