// ============================================================
// Power Query (M). Pegar cada bloque en una consulta en blanco
// (Inicio > Transformar datos > Nuevo origen > Consulta en blanco > Editor avanzado).
// 1) Crear primero el parámetro  RutaDatos  (Texto), p. ej. C:\proyecto\data\processed\
// 2) Cultura en-US para que el punto decimal se interprete bien.
// ============================================================

// ---------- fact_reportes (archivo: uap_procesado.csv) ----------
let
    Origen = Csv.Document(File.Contents(RutaDatos & "uap_procesado.csv"),
             [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Encab = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    Tipos = Table.TransformColumnTypes(Encab, {
        {"id", Int64.Type}, {"fecha", type date}, {"fecha_hora", type datetime},
        {"anio", Int64.Type}, {"mes", Int64.Type}, {"dia_semana_num", Int64.Type},
        {"hora", Int64.Type}, {"fin_de_semana", Int64.Type}, {"festivo_pirotecnia", Int64.Type},
        {"lat", type number}, {"lng", type number},
        {"pais", type text}, {"forma", type text}, {"grupo_forma", type text},
        {"duracion_seg", type number}, {"duracion_imputada", Int64.Type},
        {"duracion_atipica", Int64.Type}, {"posible_duplicado", Int64.Type},
        {"hora_conocida", Int64.Type}, {"franja_dia", type text},
        {"rango_duracion", type text}, {"rango_duracion_orden", Int64.Type}
    }, "en-US"),
    // Duración en minutos (para tarjetas y tooltips)
    DurMin = Table.AddColumn(Tipos, "duracion_min", each [duracion_seg] / 60, type number),
    // Orden de franjas para ordenar el eje (se usa 'Ordenar por columna' en el modelo)
    OrdenFranja = Table.AddColumn(DurMin, "franja_orden", each
        if Text.StartsWith([franja_dia], "Madrugada") then 1
        else if Text.StartsWith([franja_dia], "Mañana") then 2
        else if Text.StartsWith([franja_dia], "Tarde") then 3
        else if Text.StartsWith([franja_dia], "Noche") then 4
        else 5, Int64.Type),
    // Etiqueta legible para segmentadores
    EtiqPir = Table.AddColumn(OrdenFranja, "festivo_etiqueta", each
        if [festivo_pirotecnia] = 1 then "Festivo con pirotecnia" else "Día normal", type text)
in
    EtiqPir

// ---------- fact_pronostico (fact_pronostico.csv) ----------
let
    Origen = Csv.Document(File.Contents(RutaDatos & "fact_pronostico.csv"),
             [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Encab = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    Tipos = Table.TransformColumnTypes(Encab, {
        {"granularidad", type text}, {"conjunto", type text}, {"modelo", type text},
        {"fecha", type date}, {"real", type number}, {"pronostico", type number},
        {"li_95", type number}, {"ls_95", type number}, {"es_principal", Int64.Type}
    }, "en-US")
in
    Tipos

// ---------- dim_forma (dim_forma.csv) ----------
let
    Origen = Csv.Document(File.Contents(RutaDatos & "dim_forma.csv"),
             [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Encab = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    Tipos = Table.TransformColumnTypes(Encab, {{"grupo_orden", Int64.Type}}, "en-US")
in
    Tipos

// ---------- dim_pais (dim_pais.csv) ----------
let
    Origen = Csv.Document(File.Contents(RutaDatos & "dim_pais.csv"),
             [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Encab = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    Tipos = Table.TransformColumnTypes(Encab, {{"lat_centro", type number}, {"lng_centro", type number}}, "en-US")
in
    Tipos

// ---------- metricas_modelo (metricas_modelo.csv; sin relaciones) ----------
let
    Origen = Csv.Document(File.Contents(RutaDatos & "metricas_modelo.csv"),
             [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Encab = Table.PromoteHeaders(Origen, [PromoteAllScalars=true]),
    Tipos = Table.TransformColumnTypes(Encab, {
        {"MAE", type number}, {"RMSE", type number}, {"MAPE", type number},
        {"mejora_MAE_vs_ingenuo_pct", type number}}, "en-US")
in
    Tipos
