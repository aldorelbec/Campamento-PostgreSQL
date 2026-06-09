import streamlit as st
import psycopg2
import pandas as pd


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

# 2. FUNCIÓN LÓGICA PARA VALIDAR EL LOGIN CON PGCRYPTO
def validar_login(dni, password):
    conn = get_connection()
    if conn is None:
        return None
    
    cursor = conn.cursor()
    query = """
        SELECT mon_nom FROM monitor 
        WHERE mon_dni = %s 
        AND mon_pwd = crypt(%s, mon_pwd);
    """
    try:
        cursor.execute(query, (dni, password))
        resultado = cursor.fetchone()
        cursor.close()
        conn.close()
        return resultado
    except Exception as e:
        st.error(f"Error al validar credenciales en la base de datos: {e}")
        return None

# Configuración inicial de la aplicación
st.set_page_config(page_title="Gestión Campamento de Verano", layout="wide")

# LOGIN
if "logeado" not in st.session_state:
    st.session_state["logeado"] = False
    st.session_state["usuario_nombre"] = ""

# CASO A: EL USUARIO NO SE HA LOGEADO 
if not st.session_state["logeado"]:
    st.title("⛺ Sistema de Gestión - Campamento de Verano")
    st.subheader("UPIICSA | Diseño de Bases de Datos")
    st.write("---")
    
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        st.markdown("### Inicio de Sesión Administrativo")
        usuario_dni = st.text_input("DNI del Monitor / Administrador:", placeholder="Ej: BEAU001120GH4")
        usuario_pwd = st.text_input("Contraseña:", type="password", placeholder="******")
        
        if st.button("Ingresar al Sistema", type="primary", use_container_width=True):
            if usuario_dni and usuario_pwd:
                usuario_valido = validar_login(usuario_dni, usuario_pwd)
                if usuario_valido:
                    st.session_state["logeado"] = True
                    st.session_state["usuario_nombre"] = usuario_valido[0]
                    st.success(f"¡Bienvenido, {usuario_valido[0]}!")
                    st.rerun()
                else:
                    st.error("Credenciales incorrectas. Verifica tu DNI o contraseña.")
            else:
                st.warning("Por favor, rellena todos los campos.")

# CASO B: EL USUARIO YA INICIÓ SESIÓN
else:
    st.sidebar.header("👤 Sesión Activa")
    st.sidebar.write(f"Monitor: **{st.session_state['usuario_nombre']}**")
    if st.sidebar.button("Cerrar Sesión", type="secondary", use_container_width=True):
        st.session_state["logeado"] = False
        st.session_state["usuario_nombre"] = ""
        st.rerun()

    st.sidebar.write("---")
    st.sidebar.header("Configuración")


    TABLAS_CONFIG = {
        "grupo": {
            "id": "gpo_cve", 
            "columnas": ["gpo_cve", "gpo_col", "gpo_lema"], 
            "titulos": ["Clave de grupo", "Color", "Lema"]
        },
        "tienda": {
            "id": "tda_num", 
            "columnas": ["tda_num", "tda_ubi", "tda_cap"],
            "titulos": ["Número de tienda", "Ubicación", "Capacidad"]
        },
        "monitor": {
            "id": "mon_dni", 
            "columnas": ["mon_dni", "mon_nom", "mon_exp", "gpo_cve", "mon_pwd"],
            "titulos": ["DNI Monitor", "Nombre", "Experiencia", "Clave de grupo", "Contraseña Cifrada"]
        },
        "campista": {
            "id": "cam_ins", 
            "columnas": ["cam_ins", "cam_nom", "cam_app", "cam_apm", "cam_eda", "cam_dir", "cam_tel", "gpo_cve", "sgp_sec"],
            "titulos": ["Número de inscripción", "Nombre", "Apellido Paterno", "Apellido Materno", "Edad", "Dirección", "Teléfono", "Clave de grupo", "Secuencia Subgrupo"]
        },
        "subgrupo": {
            "id": "gpo_cve", 
            "columnas": ["gpo_cve", "sgp_sec", "tda_num", "cam_res", "sgp_pto"],
            "titulos": ["Clave de grupo", "Secuencia Subgrupo", "Número de tienda", "Campista Responsable", "Puntos Totales"]
        },
        "actividad": {
            "id": "act_cve", 
            "columnas": ["act_cve", "act_nom", "act_des", "act_niv", "mon_dni"],
            "titulos": ["Clave de actividad", "Nombre de actividad", "Descripción de actividad", "Nivel de Actividad", "DNI Monitor"]
        },
        "realiza_actividad": {
            "id": "gpo_cve", 
            "columnas": ["gpo_cve", "sgp_sec", "act_cve", "cam_res", "rea_pto", "rea_fec"],
            "titulos": ["Clave de grupo", "Secuencia Subgrupo", "Clave de actividad", "Campista Responsable", "Puntos", "Fecha"]
        }
    }

    tabla_seleccionada = st.sidebar.selectbox(
        "Selecciona la Tabla a Gestionar:",
        list(TABLAS_CONFIG.keys()),
        format_func=lambda x: x.upper()
    )

    st.title("⛺ Sistema de Gestión - Campamento de Verano")
    st.write(f"### Gestionando Tabla: *{tabla_seleccionada.upper()}*")

    tab1, tab2, tab3, tab4 = st.tabs(["📋 Ver Registros", "➕ Agregar", "📝 Editar", "❌ Eliminar"])

    id_campo = TABLAS_CONFIG[tabla_seleccionada]["id"]
    columnas = TABLAS_CONFIG[tabla_seleccionada]["columnas"]
    titulos = TABLAS_CONFIG[tabla_seleccionada]["titulos"]
    

    mapeo_columnas = dict(zip(titulos, columnas))

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
                    df = pd.DataFrame(datos, columns=titulos)
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
        for tit in titulos:
            valores_nuevos[tit] = st.text_input(f"Valor para {tit.upper()}:", key=f"add_{tit}")
            
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
        titulo_id = titulos[columnas.index(id_campo)]
        id_a_editar = st.text_input(f"Introduce el {titulo_id.upper()} del registro a editar:")
        
        if id_a_editar:
            valores_editados = {}
            # Filtramos para no editar la llave primaria
            titulos_a_editar = [t for t in titulos if t != titulo_id]
            
            for tit in titulos_a_editar:
                valores_editados[tit] = st.text_input(f"Nuevo valor para {tit.upper()}:", key=f"edit_{tit}")
                
            if st.button("Actualizar Registro"):
                conn = get_connection()
                if conn:
                    try:
                        cursor = conn.cursor()
                        # Traducimos los títulos modificados a sus columnas SQL reales
                        columnas_reales_editar = [mapeo_columnas[t] for t in titulos_a_editar]
                        set_clause = ", ".join([f"{col} = %s" for col in columnas_reales_editar])
                        
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
        titulo_id = titulos[columnas.index(id_campo)]
        id_a_eliminar = st.text_input(f"Introduce el {titulo_id.upper()} del registro a eliminar:")
        
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