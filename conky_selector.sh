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

            # Leer el archivo autostart existente
            local autostart_file="$HOME/.config/openbox/autostart"
            local autostart_content
            if [[ -f $autostart_file ]]; then
                autostart_content=$(<"$autostart_file")
            fi

            # Verificar si la línea de inicio de Conky ya está presente
            if ! grep -q 'conky' "$autostart_file"; then
                # Agregar la línea de inicio de Conky al archivo autostart
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

