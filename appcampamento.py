import streamlit as st
import psycopg2
import pandas as pd

# 1. FUNCIÓN DE CONEXIÓN A POSTGRESQL (MÉTODO SEGURO)
def get_connection():
    try:
        return psycopg2.connect(
            user=st.secrets["postgres"]["user"],
            password=st.secrets["postgres"]["password"],
            host=st.secrets["postgres"]["host"],
            port=st.secrets["postgres"]["port"],
            database=st.secrets["postgres"]["database"],
            client_encoding="utf8"
        )
    except Exception as e:
        st.error(f"Error de conexión a la base de datos: {e}")
        return None
# Configuración inicial de la página
st.set_page_config(page_title="Gestión Campamento de Verano", layout="wide")

st.title("⛺ Sistema de Gestión - Campamento de Verano")
st.subheader("UPIICSA | Diseño de Bases de Datos")


# PostgreSQL por defecto convierte todo a minúsculas, así aseguramos el enlace seguro.
TABLAS_CONFIG = {
    "grupo": {"id": "gpo_cve", "columnas": ["gpo_cve", "gpo_col", "gpo_lema"]},
    "tienda": {"id": "tda_num", "columnas": ["tda_num", "tda_ubi", "tda_cap"]},
    "monitor": {"id": "mon_dni", "columnas": ["mon_dni", "mon_nom", "mon_exp", "gpo_cve"]},
    "campista": {"id": "cam_ins", "columnas": ["cam_ins", "cam_nom", "cam_app", "cam_apm", "cam_eda", "cam_dir", "cam_tel", "gpo_cve", "sgp_sec"]},
    "subgrupo": {"id": "gpo_cve", "columnas": ["gpo_cve", "sgp_sec", "tda_num", "sgp_rep", "sgp_pto"]},
    "actividad": {"id": "act_cve", "columnas": ["act_cve", "act_nom", "act_des", "act_niv", "mon_dni"]},
    "realiza_actividad": {"id": "gpo_cve", "columnas": ["gpo_cve", "sgp_sec", "act_cve", "cam_res", "rea_pto", "rea_fec"]}
}

# 3. BARRA LATERAL (SIDEBAR) PARA SELECCIONAR LA TABLA
st.sidebar.header("⚙️ Configuración")
# Mostramos las opciones en mayúscula en el menú para que se vea estético (.upper())
tabla_seleccionada = st.sidebar.selectbox(
    "Selecciona la Tabla a Gestionar:",
    list(TABLAS_CONFIG.keys()),
    format_func=lambda x: x.upper()
)

st.write(f"### Gestionando Tabla: *{tabla_seleccionada.upper()}*")

# Pestañas para las operaciones CRUD
tab1, tab2, tab3, tab4 = st.tabs(["📋 Ver Registros", "➕ Agregar", "📝 Editar", "❌ Eliminar"])

# Opciones de la tabla actual
id_campo = TABLAS_CONFIG[tabla_seleccionada]["id"]
columnas = TABLAS_CONFIG[tabla_seleccionada]["columnas"]

# ==========================================
# PESTAÑA 1: LEER / MOSTRAR REGISTROS
# ==========================================
with tab1:
    conn = get_connection()
    if conn:
        try:
            cursor = conn.cursor()
            query = f"SELECT * FROM {tabla_seleccionada} ORDER BY {id_campo} ASC;"
            cursor.execute(query)
            datos = cursor.fetchall()
            
            if datos:
                df = pd.DataFrame(datos, columns=columnas)
                st.dataframe(df, use_container_width=True)
            else:
                st.info(f"La tabla '{tabla_seleccionada.upper()}' está vacía actualmente.")
            cursor.close()
        except Exception as e:
            st.error(f"Error al leer datos en PostgreSQL: {e}")
        finally:
            conn.close()

# ==========================================
# PESTAÑA 2: INSERTAR / AGREGAR
# ==========================================
with tab2:
    st.write(f"Insertar nuevo registro en *{tabla_seleccionada.upper()}*")
    valores_nuevos = {}
    
    for col in columnas:
        valores_nuevos[col] = st.text_input(f"Valor para {col.upper()}:", key=f"add_{col}")
        
    if st.button("Guardar Registro", type="primary"):
        if any(v == "" for v in valores_nuevos.values()):
            st.warning("Por favor, llena todos los campos.")
        else:
            conn = get_connection()
            if conn:
                try:
                    cursor = conn.cursor()
                    cols_str = ", ".join(columnas)
                    placeholders = ", ".join(["%s"] * len(columnas))
                    query = f"INSERT INTO {tabla_seleccionada} ({cols_str}) VALUES ({placeholders});"
                    
                    cursor.execute(query, list(valores_nuevos.values()))
                    conn.commit()
                    st.success("¡Registro guardado correctamente!")
                    st.rerun()
                except Exception as e:
                    st.error(f"Error al insertar: {e}")
                finally:
                    conn.close()

# ==========================================
# PESTAÑA 3: ACTUALIZAR / EDITAR
# ==========================================
with tab3:
    st.write(f"Modificar un registro de *{tabla_seleccionada.upper()}*")
    id_a_editar = st.text_input(f"Introduce el {id_campo.upper()} del registro a editar:")
    
    if id_a_editar:
        valores_editados = {}
        columnas_a_editar = [c for c in columnas if c != id_campo]
        
        for col in columnas_a_editar:
            valores_editados[col] = st.text_input(f"Nuevo valor para {col.upper()}:", key=f"edit_{col}")
            
        if st.button("Actualizar Registro"):
            conn = get_connection()
            if conn:
                try:
                    cursor = conn.cursor()
                    set_clause = ", ".join([f"{col} = %s" for col in columnas_a_editar])
                    query = f"UPDATE {tabla_seleccionada} SET {set_clause} WHERE {id_campo} = %s;"
                    
                    valores = list(valores_editados.values()) + [id_a_editar]
                    cursor.execute(query, valores)
                    conn.commit()
                    st.success("¡Registro actualizado con éxito!")
                    st.rerun()
                except Exception as e:
                    st.error(f"Error al actualizar: {e}")
                finally:
                    conn.close()

# ==========================================
# PESTAÑA 4: BORRAR / ELIMINAR
# ==========================================
with tab4:
    st.write(f"Eliminar un registro de *{tabla_seleccionada.upper()}*")
    id_a_eliminar = st.text_input(f"Introduce el {id_campo.upper()} del registro a eliminar:")
    
    if st.button("Eliminar permanentemente", type="secondary"):
        if id_a_eliminar:
            conn = get_connection()
            if conn:
                try:
                    cursor = conn.cursor()
                    query = f"DELETE FROM {tabla_seleccionada} WHERE {id_campo} = %s;"
                    cursor.execute(query, (id_a_eliminar,))
                    conn.commit()
                    st.success("¡Registro eliminado correctamente!")
                    st.rerun()
                except Exception as e:
                    st.error(f"Error al eliminar (Verifica restricciones de Llaves Foráneas): {e}")
                finally:
                    conn.close()
        else:
            st.warning("Por favor introduce un identificador válido.")