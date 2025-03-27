{{- define "lsc.sourceService" }}
{{- if eq .task.mode "async" -}}
<asyncLdapSourceService id="{{ .task.source.service_name | default (printf "%sSourceService" .task.name) }}">
{{- else -}}
<ldapSourceService id="{{ .task.source.service_name | default (printf "%sSourceService" .task.name) }}">
{{- end }}
  <name>{{ .task.source.service_name | default (printf "%sSourceService" .task.name) }}</name>
  <connection reference="{{ .id }}" />
  <baseDn>{{ .task.source.base_dn }}</baseDn>
  <pivotAttributes>
    {{- range $attr := .task.source.pivot_attributes }}
    <string>{{ $attr }}</string>
    {{- end }}
  </pivotAttributes>
  <fetchedAttributes>
    {{- range $attr := .task.source.fetched_attributes }}
    <string>{{ $attr }}</string>
    {{- end }}
  </fetchedAttributes>
  <getAllFilter><![CDATA[{{ .task.source.get_all_filter }}]]></getAllFilter>
  <getOneFilter><![CDATA[{{ .task.source.get_one_filter }}]]></getOneFilter>
  {{- if .task.source.clean_filter }}
  <cleanFilter><![CDATA[{{ .task.source.clean_filter }}]]></cleanFilter>
  {{- end }}
  {{- if .task.source.filter_async }}
  <filterAsync><![CDATA[{{ .task.source.filter_async }}]]></filterAsync>
  {{- end }}
  {{- if .task.source.date_format }}
  <dateFormat>{{ .task.source.date_format }}</dateFormat>
  {{- end }}
  {{- if .task.source.interval }}
  <interval>{{ .task.source.interval }}</interval>
  {{- end }}
{{- if eq .task.mode "async" }}
  {{- if not (eq .task.source.sync_on_start false) }}
  <synchronizingAllWhenStarting>true</synchronizingAllWhenStarting>
  {{- else }}
  <synchronizingAllWhenStarting>false</synchronizingAllWhenStarting>
  {{- end }}
  <serverType>{{ .task.source.server_type | default "OpenLDAP" }}</serverType>
</asyncLdapSourceService>
{{- else }}
</ldapSourceService>
{{- end }}
{{- end }}


{{- define "lsc.destinationService" -}}
<ldapDestinationService id="{{ .task.destination.name | default (printf "%sDestinationService" .task.name) }}">
  <name>{{ .task.destination.name | default (printf "%sDestinationService" .task.name) }}</name>
  <connection reference="{{ .id }}" />
  <baseDn>{{ .task.destination.base_dn }}</baseDn>
  <pivotAttributes>
    {{- range $attr := .task.destination.pivot_attributes }}
    <string>{{ $attr }}</string>
    {{- end }}
  </pivotAttributes>
  <fetchedAttributes>
    {{- range $attr := .task.destination.fetched_attributes }}
    <string>{{ $attr }}</string>
    {{- end }}
  </fetchedAttributes>
  <getAllFilter><![CDATA[{{ .task.destination.get_all_filter }}]]></getAllFilter>
  <getOneFilter><![CDATA[{{ .task.destination.get_one_filter }}]]></getOneFilter>
</ldapDestinationService>
{{- end }}


{{- define "lsc.propertiesBasedSyncOptions" -}}
<propertiesBasedSyncOptions>
  <mainIdentifier><![CDATA[{{ .main_identifier | replace "\n" "" | replace "\r" "" }}]]></mainIdentifier>
  {{- if .bean }}
  <bean>{{ .bean }}</bean>
  {{- end }}
  <defaultDelimiter>{{ .default_delimiter | default ";" }}</defaultDelimiter>
  <defaultPolicy>{{ .default_policy | default "FORCE" }}</defaultPolicy>
  {{- if .conditions }}
  <conditions>
    {{- if .conditions.create }}
    {{- if eq (printf "%v" .conditions.create)  "true" }}
    <create>true</create>
    {{- else }}
    <create><![CDATA[{{ .conditions.create | replace "\n" "" | replace "\r" "" }}]]></create>
    {{- end }}
    {{- else }}
    <create>false</create>
    {{- end }}
    {{- if .conditions.update }}
    {{- if eq (printf "%v" .conditions.update)  "true" }}
    <update>true</update>
    {{- else }}
    <update><![CDATA[{{ .conditions.update | replace "\n" "" | replace "\r" "" }}]]></update>
    {{- end }}
    {{- else }}
    <update>false</update>
    {{- end }}
    {{- if .conditions.delete }}
    {{- if eq (printf "%v" .conditions.delete)  "true" }}
    <delete>true</delete>
    {{- else }}
    <delete><![CDATA[{{ .conditions.delete | replace "\n" "" | replace "\r" "" }}]]></delete>
    {{- end }}
    {{- else }}
    <delete>false</delete>
    {{- end }}
    {{- if .conditions.change_id }}
    {{- if eq (printf "%v" .conditions.change_id)  "true" }}
    <changeId>true</changeId>
    {{- else }}
    <changeId><![CDATA[{{ .conditions.change_id | replace "\n" "" | replace "\r" "" }}]]></changeId>
    {{- end }}
    {{- else }}
    <changeId>false</changeId>
    {{- end }}
  </conditions>
  {{- end }}
  {{- if .datasets }}
  {{- range $dataset := .datasets }}
  <dataset>
    <name>{{ $dataset.name }}</name>
    {{- if $dataset.policy }}
    <policy>{{ $dataset.policy }}</policy>
    {{- end }}
    {{- if $dataset.default_values }}
    <defaultValues>
      {{- range $value := $dataset.default_values }}
      <string>{{ $value | replace "\n" "" | replace "\r" "" }}</string>
      {{- end }}
    </defaultValues>
    {{- end }}
    {{- if $dataset.force_values }}
    <forceValues>
      {{- range $value := $dataset.force_values }}
      <string><![CDATA[{{ $value | replace "\n" "" | replace "\r" "" }}]]></string>
      {{- end }}
    </forceValues>
    {{- end }}
    {{- if $dataset.create_values }}
    <createValues>
      {{- range $value := $dataset.create_values }}
      <string>{{ $value | replace "\n" "" | replace "\r" "" }}</string>
      {{- end }}
    </createValues>
    {{- end }}
    {{- if $dataset.delimiter }}
    <delimiter>{{ $dataset.delimiter }}</delimiter>
    {{- end }}
  </dataset>
  {{- end }}
  {{- end }}
</propertiesBasedSyncOptions>
{{- end }}
