import SwiftUI
import CoreData
import UIKit

//VISTA PRINCIPAL
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("modoOscuro") private var modoOscuro = false
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \PezEntity.nombre, ascending: true)],
        animation: .default)
    private var todosLosPeces: FetchedResults<PezEntity>
    
    var body: some View {
        TabView {
            PantallaPrincipal(todosLosPeces: todosLosPeces)
                .tabItem { Label("Inicio", systemImage: "house.fill") }
            
            PantallaFavoritos()
                .tabItem { Label("Favoritos", systemImage: "heart.fill") }
            
            PantallaEducacion()
                .tabItem { Label("Educación", systemImage: "book.fill") }
            
            PantallaAjustes()
                .tabItem { Label("Ajustes", systemImage: "gearshape.fill") }
        }
        .accentColor(.cyan)
        .preferredColorScheme(modoOscuro ? .dark : .light)
        .onAppear {
            if todosLosPeces.isEmpty { cargarBaseDeDatosInicial() }
        }
    }
    
    private func cargarBaseDeDatosInicial() {
        let datosIniciales: [(String, String, String)] = [
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

// Fondo dinamico
struct FondoMarino: View {
    @AppStorage("modoOscuro") private var modoOscuro = false
    
    var body: some View {
        
        let coloresOscuros = [Color.black, Color(red: 0.0, green: 0.1, blue: 0.3)]
        let coloresClaros = [Color(red: 0.0, green: 0.3, blue: 0.6), Color.blue]
        let gradiente = Gradient(colors: modoOscuro ? coloresOscuros : coloresClaros)
        
        LinearGradient(gradient: gradiente, startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

// PANTALLA 1: INICIO
struct PantallaPrincipal: View {
    @State private var textoBusqueda: String = ""
    var todosLosPeces: FetchedResults<PezEntity>
    var body: some View {
        NavigationView {
            ZStack {
                FondoMarino()
                
                VStack(alignment: .leading) {
                    Text("Happy Fish =]")
                        .font(.title).bold().padding(.horizontal).padding(.top, 20).foregroundColor(.white)
                        .accessibilityAddTraits(.isHeader)
                    
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("Busca un pescado...", text: $textoBusqueda).font(.body)
                    }
                    .padding().background(Color(.systemGray6)).cornerRadius(20).padding(.horizontal)
                    
                    if textoBusqueda.isEmpty {
                        Text("Zonas Pesqueras")
                            .font(.title2).bold().padding(.horizontal).padding(.top, 20).foregroundColor(.white)
                        
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

// PANTALLA 2: ZONAS
struct VistaZona: View {
    var nombreZona: String
    var peces: [PezEntity]
    
    var body: some View {
        ZStack {
            FondoMarino()
            VStack {
                Text("Especies en \(nombreZona)").font(.title).bold().foregroundColor(.white).padding(.top, 20)
                
                let pecesOrdenados = peces.sorted { prioridadSemaforo($0.colorSemaforo) < prioridadSemaforo($1.colorSemaforo) }
                List(pecesOrdenados, id: \.self) { pez in FilaPez(pez: pez) }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

// PANTALLA 3: FAVORITOS
struct PantallaFavoritos: View {
    @FetchRequest(
        entity: PezEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \PezEntity.nombre, ascending: true)],
        predicate: NSPredicate(format: "esFavorito == true"),
        animation: .default)
    private var pecesFavoritos: FetchedResults<PezEntity>
    
    var body: some View {
        NavigationView {
            ZStack {
                FondoMarino()
                
                let favoritosOrdenados = pecesFavoritos.sorted { prioridadSemaforo($0.colorSemaforo) < prioridadSemaforo($1.colorSemaforo) }
                
                if favoritosOrdenados.isEmpty {
                    Text("Aún no tienes peces favoritos.").foregroundColor(.white).opacity(0.8)
                } else {
                    List(favoritosOrdenados, id: \.self) { pez in
                        FilaPez(pez: pez)
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Mis Favoritos")
        }
    }
}

// PANTALLA 4: EDUCACIÓN
struct PantallaEducacion: View {
    var body: some View {
        NavigationView {
            ZStack {
                FondoMarino()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Misión ODS 14").font(.largeTitle).bold().foregroundColor(.white)
                        Text("Vida Submarina").font(.title2).foregroundColor(.cyan)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            TarjetaInfo(titulo: "¿Sabías qué?", texto: "Los océanos absorben alrededor del 30% del dióxido de carbono producido por los humanos.", icono: "globe.americas.fill")
                            TarjetaInfo(titulo: "Pesca Sostenible", texto: "Respetar las vedas permite que las especies marinas se reproduzcan.", icono: "exclamationmark.triangle.fill")
                            TarjetaInfo(titulo: "Tu Impacto", texto: "Al usar Happy Fish =], ayudas a promover prácticas responsables.", icono: "hand.thumbsup.fill")
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// PANTALLA 5: AJUSTES
struct PantallaAjustes: View {
    @AppStorage("modoOscuro") private var modoOscuro = false
    @AppStorage("vibracionActivada") private var vibracionActivada = true
    @State private var mostrarAlertaBorrado = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Apariencia y Accesibilidad")) {
                    Toggle(isOn: $modoOscuro) { Label("Modo Oscuro Fijo", systemImage: "moon.fill") }
                        .onChange(of: modoOscuro) { generarVibracion() }
                }
                Section(header: Text("Preferencias de la App")) {
                    Toggle(isOn: $vibracionActivada) { Label("Vibración al tocar botones", systemImage: "iphone.radiowaves.left.and.right") }
                        .onChange(of: vibracionActivada) { generarVibracion() }
                }
                Section(header: Text("Gestión de Datos")) {
                    Button(role: .destructive, action: { mostrarAlertaBorrado = true; generarVibracion() }) {
                        Label("Quitar todos mis Favoritos", systemImage: "trash.fill")
                    }
                    .alert("¿Estás seguro?", isPresented: $mostrarAlertaBorrado) {
                        Button("Cancelar", role: .cancel) { }
                        Button("Borrar Todo", role: .destructive) { borrarTodosLosFavoritos() }
                    }
                }
            }
            .navigationTitle("Ajustes")
        }
    }
    
    private func generarVibracion() {
        if vibracionActivada { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    }
    private func borrarTodosLosFavoritos() {
        let request = NSFetchRequest<PezEntity>(entityName: "PezEntity")
        request.predicate = NSPredicate(format: "esFavorito == true")
        if let favoritos = try? viewContext.fetch(request) {
            for pez in favoritos { pez.esFavorito = false }
            try? viewContext.save()
            generarVibracion()
        }
    }
}

// COMPONENTES
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

struct TarjetaInfo: View {
    var titulo: String; var texto: String; var icono: String
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icono).foregroundColor(.cyan).font(.title2)
                Text(titulo).font(.headline).foregroundColor(.white)
            }
            Text(texto).font(.body).foregroundColor(.white).opacity(0.9)
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(15)
        .accessibilityElement(children: .combine)
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
        }
        .listRowBackground(Color.black.opacity(0.2))
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

func prioridadSemaforo(_ colorTexto: String?) -> Int {
    switch colorTexto {
    case "Verde": return 1
    case "Amarillo": return 2
    case "Rojo": return 3
    default: return 4
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
