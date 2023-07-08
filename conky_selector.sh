#!/bin/bash
#
# Este programa es software libre: puedes redistribuirlo y/o modificar
# bajo los términos de la Licencia Pública General GNU publicada por
# la Free Software Foundation, ya sea la versión 3 de la Licencia, o
# (a su elección) cualquier versión posterior.
#
# Este programa se distribuye con la esperanza de que sea útil,
# pero SIN NINGUNA GARANTÍA; sin siquiera la garantía implícita de
# COMERCIABILIDAD o IDONEIDAD PARA UN FIN DETERMINADO. Vea la
# Licencia Pública General GNU para más detalles.
#
# Licencia Pública General GNU consulte <http://www.gnu.org/licenses/>.
#
# Ejecutar con la orden bash conky_selector.sh
###################################################################
#!/bin/bash

# Ruta de la carpeta de temas de Conky
theme_dir="$HOME/.config/conky/"

# Obtener lista de temas disponibles
theme_names=()
i=1
for theme in "$theme_dir"/*.conf; do
    theme_name=$(basename "$theme" .conf)
    theme_names+=("$theme_name")
done

# Función para mostrar el menú de selección de temas
function show_menu() {
    clear
    echo " Bienvenido al Selector de Temas de C O N K Y"
    echo " Nota: después de seleccionar su tema, seleccione la opción 'Salir' para guardar los cambios"
    echo " "
    echo " Seleccione un tema:"
    echo

    # Configurar el prompt para mostrar la opción seleccionada
    PS3=" Ingrese el número de opción: "

    # Crear el menú select con los temas disponibles
    select theme_option in "${theme_names[@]}" "Salir"; do
        if [[ $REPLY -eq $(( ${#theme_names[@]} + 1 )) ]]; then
            # El usuario seleccionó "Salir"
            exit 0
        elif [[ $REPLY -gt 0 && $REPLY -le ${#theme_names[@]} ]]; then
            # El usuario seleccionó un tema válido
            local selected_theme="${theme_names[$((REPLY-1))]}"
            echo " Tema de Conky actualizado a: $selected_theme.conf"
            cp "$theme_dir$selected_theme.conf" "$HOME/.conkyrc"

            # Actualizar el contenido del archivo autostart
            local autostart_file="$HOME/.config/openbox/autostart"

            # Verificar si la línea de inicio de Conky ya existe en el archivo autostart
            if ! grep -q "# Inicio de Conky" "$autostart_file"; then
                # Eliminar líneas existentes que contengan 'conky'
                sed -i '/conky/d' "$autostart_file"
                # Agregar comentario y la línea de inicio de Conky al archivo autostart
                echo "# Inicio de Conky" >> "$autostart_file"
                echo "(sleep 2 && conky) &" >> "$autostart_file"
            fi

            pkill -x conky  # Matar cualquier instancia existente de Conky
            nohup conky >/dev/null 2>&1 & # Ejecutar Conky en segundo plano con nohup
        else
            # Opción inválida
            echo " Opción inválida. Inténtelo de nuevo."
        fi

        show_menu
    done
}

show_menu
