import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
   
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PezEntity.nombre, ascending: true)],
        animation: .default)
    private var todosLosPeces: FetchedResults<PezEntity>
   
    var body: some View {
        TabView {
            PantallaPrincipal(todosLosPeces: todosLosPeces)
                .tabItem { Label("Inicio", systemImage: "house.fill") }
           
            PantallaFavoritos(todosLosPeces: todosLosPeces)
                .tabItem { Label("Favoritos", systemImage: "heart.fill") }
        }
        .accentColor(.cyan)
        .onAppear {
            if todosLosPeces.isEmpty {
                cargarBaseDeDatosInicial()
            }
        }
    }
   
    private func cargarBaseDeDatosInicial() {
        let datosIniciales = [
            ("Dorado (Mahi-Mahi)", "Golfo de México", "Verde"),
            ("Lisa Rayada (Mullet)", "Golfo de México", "Verde"),
            ("Huachinango del Golfo", "Golfo de México", "Amarillo"),
            ("Marlín Azul del Atlántico", "Golfo de México", "Amarillo"),
            ("Pez Sierra (Dientes Pequeños)", "Golfo de México", "Rojo"),
            ("Mero de Nassau", "Golfo de México", "Rojo"),
            ("Salmón Rojo (Sockeye)", "Alaska", "Verde"),
            ("Halibut del Pacífico", "Alaska", "Verde"),
            ("Cangrejo Real (Regulado)", "Alaska", "Amarillo"),
            ("León Marino (Protegido)", "Alaska", "Rojo"),
            ("Langosta Americana", "Nueva Inglaterra", "Verde"),
            ("Vieiras (Scallops)", "Nueva Inglaterra", "Verde"),
            ("Bacalao del Atlántico", "Nueva Inglaterra", "Rojo"),
            ("Ballena Franca (Protegida)", "Nueva Inglaterra", "Rojo")
        ]
       
        for dato in datosIniciales {
            let nuevoPez = PezEntity(context: viewContext)
            nuevoPez.nombre = dato.0
            nuevoPez.zona = dato.1
            nuevoPez.colorSemaforo = dato.2
            nuevoPez.esFavorito = false
        }
        try? viewContext.save()
    }
}

// PANTALLA PRINCIPAL
struct PantallaPrincipal: View {
    @State private var textoBusqueda: String = ""
    var todosLosPeces: FetchedResults<PezEntity>
   
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.1, blue: 0.3), Color.blue]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
               
                VStack(alignment: .leading) {
                    Text("Happy Fish =]")
                        .font(.title).bold().padding(.horizontal).padding(.top, 20).foregroundStyle(.white)
                        .accessibilityAddTraits(.isHeader)
                   
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Busca un pescado...", text: $textoBusqueda).font(.body)
                    }
                    .padding().background(Color(.systemGray6)).cornerRadius(20).padding(.horizontal)
                    .accessibilityLabel("Barra de búsqueda de especies")
                   
                    if textoBusqueda.isEmpty {
                        Text("Zonas Pesqueras")
                            .font(.title2).bold().padding(.horizontal).padding(.top, 20).foregroundStyle(.white)
                       
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                NavigationLink(destination: VistaZona(nombreZona: "Alaska", peces: todosLosPeces.filter { $0.zona == "Alaska" })) {
                                    TarjetaCategoria(icono: "mappin.and.ellipse", nombre: "Alaska", color: .blue)
                                }
                                NavigationLink(destination: VistaZona(nombreZona: "Golfo de México", peces: todosLosPeces.filter { $0.zona == "Golfo de México" })) {
                                    TarjetaCategoria(icono: "mappin.and.ellipse", nombre: "Golfo de MX", color: .teal)
                                }
                                NavigationLink(destination: VistaZona(nombreZona: "Nueva Inglaterra", peces: todosLosPeces.filter { $0.zona == "Nueva Inglaterra" })) {
                                    TarjetaCategoria(icono: "mappin.and.ellipse", nombre: "N. Inglaterra", color: .indigo)
                                }
                            }
                            .padding(.horizontal).padding(.top, 5)
                        }
                       
                        VStack(alignment: .leading, spacing: 12) {
                            Text("¿Cómo funciona el semáforo?")
                                .font(.headline).foregroundColor(.white).padding(.bottom, 5)
                            HStack { Circle().fill(Color.green).frame(width: 15, height: 15); Text("Verde: Permitida.").foregroundColor(.white).font(.subheadline) }
                            HStack { Circle().fill(Color.yellow).frame(width: 15, height: 15); Text("Amarillo: Regulada.").foregroundColor(.white).font(.subheadline) }
                            HStack { Circle().fill(Color.red).frame(width: 15, height: 15); Text("Rojo: Protegida.").foregroundColor(.white).font(.subheadline) }
                        }
                        .padding(.horizontal).padding(.top, 25)
                        .accessibilityElement(children: .combine)
                       
                        Spacer()
                    } else {
                        List {
                            // AQUÍ ORDENAMOS LA BÚSQUEDA POR COLOR
                            let resultados = todosLosPeces
                                .filter { $0.nombre?.localizedCaseInsensitiveContains(textoBusqueda) == true }
                                .sorted { prioridadSemaforo($0.colorSemaforo) < prioridadSemaforo($1.colorSemaforo) }
                           
                            if resultados.isEmpty {
                                Text("No se encontró ningún pez.").foregroundColor(.white).listRowBackground(Color.clear)
                            } else {
                                ForEach(resultados, id: \.self) { pez in FilaPez(pez: pez) }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
        }
    }
}

// PANTALLA DE ZONAS
struct VistaZona: View {
    var nombreZona: String
    var peces: [PezEntity]
   
    var body: some View {
        ZStack {
            Color(red: 0.0, green: 0.1, blue: 0.3).ignoresSafeArea()
            VStack {
                Text("Especies en \(nombreZona)").font(.title).bold().foregroundColor(.white).padding(.top, 20)
               
                // AQUÍ ORDENAMOS LAS ZONAS POR COLOR
                let pecesOrdenados = peces.sorted { prioridadSemaforo($0.colorSemaforo) < prioridadSemaforo($1.colorSemaforo) }
               
                List(pecesOrdenados, id: \.self) { pez in FilaPez(pez: pez) }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

// PANTALLA DE FAVORITOS
struct PantallaFavoritos: View {
    var todosLosPeces: FetchedResults<PezEntity>
   
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.0, green: 0.1, blue: 0.3).ignoresSafeArea()
               
                // AQUÍ ORDENAMOS LOS FAVORITOS POR COLOR
                let favoritos = todosLosPeces
                    .filter { $0.esFavorito }
                    .sorted { prioridadSemaforo($0.colorSemaforo) < prioridadSemaforo($1.colorSemaforo) }
               
                if favoritos.isEmpty {
                    Text("Aún no tienes peces favoritos.").foregroundColor(.gray)
                } else {
                    List(favoritos, id: \.self) { pez in FilaPez(pez: pez) }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Mis Favoritos")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// COMPONENTES REUTILIZABLES
struct TarjetaCategoria: View {
    var icono: String; var nombre: String; var color: Color
    var body: some View {
        VStack {
            Image(systemName: icono).font(.largeTitle).foregroundColor(.white).padding(.bottom, 5)
            Text(nombre).font(.headline).foregroundColor(.white)
        }
        .frame(width: 125, height: 110).background(color).cornerRadius(20)
    }
}

struct FilaPez: View {
    @ObservedObject var pez: PezEntity
    @Environment(\.managedObjectContext) private var viewContext
   
    var body: some View {
        HStack {
            Circle().fill(colorPara(pez.colorSemaforo ?? "")).frame(width: 20, height: 20)
            Text(pez.nombre ?? "").font(.headline).foregroundColor(.white)
            Spacer()
            Button(action: {
                pez.esFavorito.toggle()
                try? viewContext.save()
            }) {
                Image(systemName: pez.esFavorito ? "heart.fill" : "heart")
                    .foregroundColor(pez.esFavorito ? .red : .gray).font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(pez.esFavorito ? "Quitar de favoritos" : "Añadir a favoritos")
        }
        .listRowBackground(Color.blue.opacity(0.3))
    }
   
    func colorPara(_ colorTexto: String) -> Color {
        switch colorTexto {
        case "Verde": return .green
        case "Amarillo": return .yellow
        case "Rojo": return .red
        default: return .gray
        }
    }
}

// LÓGICA DE ORDENAMIENTO (Asignamos un número a cada color)
func prioridadSemaforo(_ colorTexto: String?) -> Int {
    switch colorTexto {
    case "Verde": return 1
    case "Amarillo": return 2
    case "Rojo": return 3
    default: return 4
    }
}
