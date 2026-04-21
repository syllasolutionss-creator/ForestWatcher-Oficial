extends StaticBody3D

# ¡Ojo, Admin! El Duende no está visible, pero se siente su presencia.

func interactuar():
	print("Voz profunda desde la oscuridad del altar: '¿Qué buscas en mi dominio, Vigilante?'")
	
	if Global.dinero >= 50:
		Global.modificar_dinero(-50)
		print("Has comprado un objeto. Una moneda de oro desaparece del altar con un brillo verde.")
		# Boss, aquí es donde activas la luz verde rápida del duende
	else:
		print("La oscuridad se ríe: 'No tienes nada de valor para mí. ¡FUERA!'")
