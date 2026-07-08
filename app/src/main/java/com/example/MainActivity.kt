package com.example

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.asPaddingValues
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.LocalMall
import androidx.compose.material.icons.filled.LocalShipping
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.IconButton
import androidx.compose.material3.Divider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.ui.geometry.Offset
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.RadioButton
import androidx.compose.material3.RadioButtonDefaults
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.CreditCard
import androidx.compose.material.icons.filled.QrCode
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Warning
import com.example.MercadoPagoService
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.UniEatsTheme
import kotlinx.coroutines.delay
import androidx.compose.runtime.rememberCoroutineScope
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    enableEdgeToEdge()
    setContent {
      UniEatsTheme {
        AppNavigation()
      }
    }
  }
}

// Simple Model Classes representing luxury curated partners & items
data class Restaurant(
  val id: String,
  val name: String,
  val category: String,
  val rating: Double,
  val distance: String,
  val deliveryTime: String,
  val deliveryFee: String,
  val tag: String,
  val imageResId: Int,
  val signatureDishes: List<Dish>
)

data class Dish(
  val name: String,
  val price: String,
  val description: String
)

data class Order(
  val id: String,
  val customerName: String,
  val customerPhone: String,
  val customerAddress: String,
  val orderTime: String,
  val items: List<OrderItem>,
  val notes: String,
  val deliveryType: String, // "Entregador da Loja" ou "Rede Uni eats"
  val status: OrderStatus,
  val total: String
)

data class OrderItem(
  val name: String,
  val quantity: Int,
  val price: String
)

enum class OrderStatus {
  NOVOS, PREPARO, PRONTOS
}

enum class TipoCidade {
  INTERIOR,
  CAPITAL
}

object CalculadoraLogisticaService {
  fun calcularTaxaPorEndereco(tipo: TipoCidade): Double {
    return when (tipo) {
      TipoCidade.INTERIOR -> 4.0
      TipoCidade.CAPITAL -> 6.0
    }
  }

  fun calcularParcelaCliente(tipo: TipoCidade): Double {
    return when (tipo) {
      TipoCidade.INTERIOR -> 2.0
      TipoCidade.CAPITAL -> 3.0
    }
  }

  fun calcularParcelaRestaurante(tipo: TipoCidade): Double {
    return when (tipo) {
      TipoCidade.INTERIOR -> 2.0
      TipoCidade.CAPITAL -> 3.0
    }
  }
}

@Composable
fun AppNavigation() {
  var showSplash by remember { mutableStateOf(true) }

  LaunchedEffect(Unit) {
    // 2.5 seconds splash display to set the elite mood
    delay(2500)
    showSplash = false
  }

  Crossfade(
    targetState = showSplash,
    animationSpec = tween(1000, easing = FastOutSlowInEasing),
    label = "SplashToHomeTransition"
  ) { isSplash ->
    if (isSplash) {
      SplashScreen()
    } else {
      HomeScreen()
    }
  }
}

@Composable
fun SplashScreen() {
  val scale = remember { Animatable(0.85f) }
  val alpha = remember { Animatable(0f) }

  LaunchedEffect(Unit) {
    scale.animateTo(
      targetValue = 1.05f,
      animationSpec = tween(1800, easing = FastOutSlowInEasing)
    )
  }

  LaunchedEffect(Unit) {
    alpha.animateTo(
      targetValue = 1f,
      animationSpec = tween(1000)
    )
  }

  Box(
    modifier = Modifier
      .fillMaxSize()
      .background(MaterialTheme.colorScheme.background)
      .testTag("splash_container"),
    contentAlignment = Alignment.Center
  ) {
    // Elegant radial decorative glow in the background
    Box(
      modifier = Modifier
        .fillMaxSize()
        .alpha(0.08f)
        .background(
          Brush.radialGradient(
            colors = listOf(MaterialTheme.colorScheme.primary, Color.Transparent),
            radius = 1200f
          )
        )
    )

    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalArrangement = Arrangement.Center,
      modifier = Modifier
        .scale(scale.value)
        .alpha(alpha.value)
        .padding(32.dp)
    ) {
      Text(
        text = "Uni eats",
        style = MaterialTheme.typography.displayLarge.copy(
          color = MaterialTheme.colorScheme.primary,
          fontWeight = FontWeight.Light,
          fontSize = 44.sp,
          letterSpacing = 4.sp
        ),
        textAlign = TextAlign.Center,
        modifier = Modifier.testTag("splash_title")
      )
      
      Spacer(modifier = Modifier.height(12.dp))
      
      Box(
        modifier = Modifier
          .width(48.dp)
          .height(1.dp)
          .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.6f))
      )

      Spacer(modifier = Modifier.height(16.dp))

      Text(
        text = "CURADORIA CULINÁRIA EXCLUSIVA",
        style = MaterialTheme.typography.labelSmall.copy(
          color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f),
          fontWeight = FontWeight.Medium,
          letterSpacing = 3.sp
        ),
        textAlign = TextAlign.Center
      )
    }

    // Elegant subtitle at the bottom
    Text(
      text = "SAAS PREMIUM EXPERIENCE",
      style = MaterialTheme.typography.labelSmall.copy(
        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.4f),
        fontWeight = FontWeight.Bold,
        letterSpacing = 4.sp
      ),
      modifier = Modifier
        .align(Alignment.BottomCenter)
        .navigationBarsPadding()
        .padding(bottom = 32.dp)
    )
  }
}


data class SimulatedSaleKotlin(
  val orderId: String,
  val orderValue: Double,
  val cityType: TipoCidade,
  val timestamp: Long = System.currentTimeMillis()
)

data class CompletedRouteKotlin(
  val name: String,
  val addressesCount: Int,
  val earnings: Double,
  val status: String,
  val timestamp: Long = System.currentTimeMillis()
)

@Composable
fun HomeScreen() {
  // Dynamic state containing the premium restaurants including hamburgers, pizzas, and pastéis
  var restaurantList by remember {
    mutableStateOf(
      listOf(
        Restaurant(
          id = "1",
          name = "Kuroshio Luxury Sushi",
          category = "Gourmet",
          rating = 4.9,
          distance = "1.2 km",
          deliveryTime = "30-40 min",
          deliveryFee = "Grátis",
          tag = "Michelin 2026",
          imageResId = R.drawable.img_restaurant_1_1783374596071,
          signatureDishes = listOf(
            Dish("Omakase Especial (16 Peças)", "R$ 380,00", "Seleção do chef com peixes nobres do dia, trufas negras e raspas de ouro comestível."),
            Dish("Sashimi de Atum Bluefin", "R$ 195,00", "5 fatias de corte gordo (Otoro) de Atum Bluefin importado com wasabi fresco."),
            Dish("Caviar Golden Imperial (30g)", "R$ 820,00", "Servido sobre gelo picado com blinis caseiros e creme fraiche.")
          )
        ),
        Restaurant(
          id = "2",
          name = "Trattoria Della Terrazza",
          category = "Massas",
          rating = 4.8,
          distance = "2.4 km",
          deliveryTime = "35-45 min",
          deliveryFee = "R$ 18,00",
          tag = "Exclusivo Uni",
          imageResId = R.drawable.img_restaurant_2_1783374606197,
          signatureDishes = listOf(
            Dish("Tagliolini com Trufas Brancas", "R$ 290,00", "Massa fresca artesanal ao molho de manteiga da Normandia com trufas raladas na hora."),
            Dish("Gnocchi Al Tartufo & Caviar", "R$ 320,00", "Gnocchi dourado recheado com queijo Fontina e toque final de ovas de salmão."),
            Dish("Filé Mignon ao Molho Brunello", "R$ 185,00", "Grelhado na brasa ao demi-glace de vinho Brunello di Montalcino.")
          )
        ),
        Restaurant(
          id = "3",
          name = "Le Burguer Truffé",
          category = "Hambúrguer",
          rating = 4.9,
          distance = "0.8 km",
          deliveryTime = "20-30 min",
          deliveryFee = "Grátis",
          tag = "Artesanal Gold",
          imageResId = R.drawable.img_burger_1783375467965,
          signatureDishes = listOf(
            Dish("Wagyu Truffle Burger", "R$ 115,00", "Blend de Wagyu A5 180g, queijo Gruyère derretido, maionese de trufas brancas e pão de brioche dourado."),
            Dish("L'Or Burger", "R$ 180,00", "Burguer artesanal de 180g banhado em folhas de ouro comestíveis com foie gras ralado.")
          )
        ),
        Restaurant(
          id = "4",
          name = "Pizzeria di Lusso",
          category = "Pizza",
          rating = 4.7,
          distance = "1.9 km",
          deliveryTime = "25-35 min",
          deliveryFee = "R$ 12,00",
          tag = "Forno de Pedra",
          imageResId = R.drawable.img_pizza_1783375478991,
          signatureDishes = listOf(
            Dish("Burrata & Tartufo Pizza", "R$ 145,00", "Molho de tomate San Marzano, burrata cremosa fresca e trufas negras raladas com raspas de limão siciliano."),
            Dish("Pizza Prosciutto & Figos", "R$ 160,00", "Prosciutto di Parma especial curado 24 meses, figos frescos grelhados e redução de aceto balsâmico envelhecido.")
          )
        ),
        Restaurant(
          id = "5",
          name = "Pastelaria Imperial",
          category = "Pastel",
          rating = 4.9,
          distance = "3.1 km",
          deliveryTime = "15-25 min",
          deliveryFee = "R$ 9,00",
          tag = "Fritura Perfeita",
          imageResId = R.drawable.img_pastel_1783375489380,
          signatureDishes = listOf(
            Dish("Pastel de Camarão & Catupiry", "R$ 78,00", "Camarões pistola salteados com o legítimo requeijão cremoso Catupiry em massa ultra leve e crocante."),
            Dish("Pastel Brie com Damasco", "R$ 65,00", "Queijo Brie francês derretido sob geleia artesanal de damasco e mel de laranjeira silvestre.")
          )
        )
      )
    )
  }

  // State Management
  var orderList by remember {
    mutableStateOf(
      listOf(
        Order(
          id = "#2084",
          customerName = "Guilherme S. Prado",
          customerPhone = "+55 11 99888-7766",
          customerAddress = "Alameda Lorena, 1200 - Jardins, SP",
          orderTime = "14:48",
          items = listOf(
            OrderItem("Wagyu Truffle Burger", 2, "R$ 115,00"),
            OrderItem("Batata Trufada Rústica", 1, "R$ 45,00")
          ),
          notes = "Ponto do Wagyu bem vermelho. Sem picles, por favor.",
          deliveryType = "Rede Uni eats",
          status = OrderStatus.NOVOS,
          total = "R$ 275,00"
        ),
        Order(
          id = "#2083",
          customerName = "Beatriz de Cavalcante",
          customerPhone = "+55 11 97766-5544",
          customerAddress = "Av. Paulista, 1500 - Consolação, SP",
          orderTime = "14:32",
          items = listOf(
            OrderItem("Burrata & Tartufo Pizza", 1, "R$ 145,00")
          ),
          notes = "Por favor, caprichar no azeite trufado fresco.",
          deliveryType = "Entregador da Loja",
          status = OrderStatus.PREPARO,
          total = "R$ 145,00"
        ),
        Order(
          id = "#2082",
          customerName = "Dr. Alexandre Alencar",
          customerPhone = "+55 11 91234-5678",
          customerAddress = "Rua Bela Cintra, 2300 - Cerqueira César, SP",
          orderTime = "14:15",
          items = listOf(
            OrderItem("Pastel de Camarão & Catupiry", 3, "R$ 78,00"),
            OrderItem("Pastel Brie com Damasco", 1, "R$ 65,00")
          ),
          notes = "Enviar bem quente e crocante na embalagem especial.",
          deliveryType = "Rede Uni eats",
          status = OrderStatus.PRONTOS,
          total = "R$ 299,00"
        )
      )
    )
  }

  var searchQuery by remember { mutableStateOf("") }
  var selectedCategory by remember { mutableStateOf("Todos") }
  var selectedRestaurant by remember { mutableStateOf<Restaurant?>(null) }
  var itemsInCartCount by remember { mutableStateOf(0) }
  var showProfileDialog by remember { mutableStateOf(false) }
  var activeTab by remember { mutableStateOf("Início") }
  var selectedCityType by remember { mutableStateOf(TipoCidade.CAPITAL) }

  // Global simulation states for real-time Order Tracking (Client Screen)
  var deliveryState by remember { mutableStateOf("idle") } // "idle", "offered", "accepted"
  var journeyStep by remember { mutableStateOf(1) } // 1 = Retirada, 2 = Preparo, 3 = Rota Cliente, 4 = Entregue
  var simulationProgress by remember { mutableStateOf(0.0f) }
  var riderLatitude by remember { mutableStateOf(-23.5614) }
  var riderLongitude by remember { mutableStateOf(-46.6559) }

  var lojistaBalance by remember { mutableStateOf(1184.60) }
  val lojistaSales = remember {
    androidx.compose.runtime.mutableStateListOf<SimulatedSaleKotlin>(
      SimulatedSaleKotlin("2084", 275.0, TipoCidade.CAPITAL),
      SimulatedSaleKotlin("2083", 145.0, TipoCidade.INTERIOR),
      SimulatedSaleKotlin("2082", 299.0, TipoCidade.CAPITAL)
    )
  }

  var motoboyBalance by remember { mutableStateOf(54.00) }
  val motoboyRoutes = remember {
    androidx.compose.runtime.mutableStateListOf<CompletedRouteKotlin>(
      CompletedRouteKotlin("Rota Alameda Lorena", 3, 18.0, "Pago 100%"),
      CompletedRouteKotlin("Rota Consolação Centro", 3, 12.0, "Pago 100%")
    )
  }

  // Search & category filtration logic
  val filteredRestaurants = restaurantList.filter { restaurant ->
    val matchesSearch = restaurant.name.contains(searchQuery, ignoreCase = true) ||
                        restaurant.category.contains(searchQuery, ignoreCase = true)
    val matchesCategory = selectedCategory == "Todos" || restaurant.category == selectedCategory
    matchesSearch && matchesCategory
  }

  Scaffold(
    modifier = Modifier.fillMaxSize(),
    containerColor = MaterialTheme.colorScheme.background,
    contentWindowInsets = WindowInsets.safeDrawing,
    bottomBar = {
      LuxuryBottomNavigation(
        activeTab = activeTab,
        onTabSelected = { tab ->
          if (tab == "Perfil") {
            showProfileDialog = true
          } else {
            activeTab = tab
          }
        }
      )
    }
  ) { paddingValues ->
    Box(
      modifier = Modifier
        .fillMaxSize()
        .padding(paddingValues)
    ) {
      Crossfade(
        targetState = activeTab,
        animationSpec = tween(400),
        label = "TabContentTransition"
      ) { currentTab ->
        when (currentTab) {
          "Início" -> {
            // Main Scrollable Area
            LazyColumn(
              modifier = Modifier.fillMaxSize(),
              contentPadding = PaddingValues(bottom = 80.dp) // Space for floating bag
            ) {
              // 1. Header Minimalista
              item {
                HomeHeader(
                  onProfileClick = { showProfileDialog = true },
                  onLocationClick = { /* Simulate location sheet */ }
                )
              }

              // 2. Barra de Pesquisa Fina
              item {
                SearchBar(
                  query = searchQuery,
                  onQueryChange = { searchQuery = it }
                )
              }

              // 3. Carrossel Destaques da Semana
              item {
                HighlightsCarousel(
                  onHighlightClick = {
                    // Open first restaurant as highlighted partner
                    selectedRestaurant = restaurantList.first()
                  }
                )
              }

              // 4. Filtros Rápidos Minimalistas
              item {
                QuickFilters(
                  selectedCategory = selectedCategory,
                  onCategorySelected = { selectedCategory = it }
                )
              }

              // 5. Lista de Restaurantes (Skeleton / Cards)
              item {
                Text(
                  text = "Curadoria de Parceiros",
                  style = MaterialTheme.typography.titleLarge.copy(
                    color = MaterialTheme.colorScheme.onBackground,
                    fontWeight = FontWeight.SemiBold
                  ),
                  modifier = Modifier.padding(start = 20.dp, end = 20.dp, top = 28.dp, bottom = 12.dp)
                )
              }

              if (filteredRestaurants.isEmpty()) {
                item {
                  Box(
                    modifier = Modifier
                      .fillMaxWidth()
                      .padding(vertical = 48.dp, horizontal = 24.dp),
                    contentAlignment = Alignment.Center
                  ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                      Icon(
                        imageVector = Icons.Default.Search,
                        contentDescription = "Sem resultados",
                        tint = MaterialTheme.colorScheme.primary.copy(alpha = 0.4f),
                        modifier = Modifier.size(48.dp)
                      )
                      Spacer(modifier = Modifier.height(16.dp))
                      Text(
                        text = "Nenhum parceiro atende aos critérios selecionados.",
                        style = MaterialTheme.typography.bodyMedium.copy(
                          color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
                        ),
                        textAlign = TextAlign.Center
                      )
                    }
                  }
                }
              } else {
                items(filteredRestaurants) { restaurant ->
                  RestaurantCard(
                    restaurant = restaurant,
                    onClick = { selectedRestaurant = restaurant }
                  )
                }
              }
            }
          }
          "Explorar" -> {
            ExplorarScreenContent(
              restaurantList = restaurantList,
              onRestaurantClick = { selectedRestaurant = it }
            )
          }
          "Rastrear" -> {
            RastrearScreenContent(
              deliveryState = deliveryState,
              journeyStep = journeyStep,
              simulationProgress = simulationProgress,
              riderLatitude = riderLatitude,
              riderLongitude = riderLongitude,
              selectedCityType = selectedCityType,
              orderList = orderList,
              onNavigateToExplore = { activeTab = "Início" }
            )
          }
          "Chef" -> {
            ChefPanelContent(
              restaurantList = restaurantList,
              orderList = orderList,
              selectedCityType = selectedCityType,
              onCityTypeChange = { selectedCityType = it },
              onUpdateRestaurants = { updatedList ->
                restaurantList = updatedList
              },
              onUpdateOrders = { updatedOrders ->
                orderList = updatedOrders
              },
              lojistaBalance = lojistaBalance,
              onUpdateLojistaBalance = { lojistaBalance = it },
              lojistaSales = lojistaSales,
              motoboyBalance = motoboyBalance,
              onUpdateMotoboyBalance = { motoboyBalance = it },
              motoboyRoutes = motoboyRoutes,
              parentDeliveryState = deliveryState,
              parentJourneyStep = journeyStep,
              parentSimulationProgress = simulationProgress,
              parentRiderLatitude = riderLatitude,
              parentRiderLongitude = riderLongitude,
              onDeliverySimulationUpdate = { state, step, progress, lat, lng ->
                deliveryState = state
                journeyStep = step
                simulationProgress = progress
                riderLatitude = lat
                riderLongitude = lng
              }
            )
          }
          "Sacola" -> {
            SacolaScreenContent(
              itemsCount = itemsInCartCount,
              selectedCityType = selectedCityType,
              onCityTypeChange = { selectedCityType = it },
              onClearCart = { itemsInCartCount = 0 },
              onOrderCreated = { newOrder ->
                orderList = orderList + newOrder
                itemsInCartCount = 0
                val totalStr = newOrder.total.replace("R$", "").replace(",", ".").trim()
                val totalVal = totalStr.toDoubleOrNull() ?: 50.0
                val logisticDeduction = if (selectedCityType == TipoCidade.CAPITAL) 3.0 else 2.0
                val platformSaaS = 0.8
                lojistaBalance += (totalVal - logisticDeduction - platformSaaS)
                lojistaSales.add(0, SimulatedSaleKotlin(
                  orderId = newOrder.id.replace("#", ""),
                  orderValue = totalVal,
                  cityType = selectedCityType
                ))
                // Activate Tracking Screen with fresh offered state
                deliveryState = "offered"
                journeyStep = 1
                simulationProgress = 0.0f
                activeTab = "Rastrear"
              },
              onNavigateToChef = {
                activeTab = "Chef"
              }
            )
          }
        }
      }

      // Floating Elegante "Sacola de Compras" se houver itens
      AnimatedVisibility(
        visible = itemsInCartCount > 0,
        enter = slideInVertically(initialOffsetY = { h -> h }) + fadeIn(),
        exit = slideOutVertically(targetOffsetY = { h -> h }) + fadeOut(),
        modifier = Modifier
          .align(Alignment.BottomCenter)
          .navigationBarsPadding()
          .padding(bottom = 16.dp, start = 20.dp, end = 20.dp)
      ) {
        FloatingCartButton(
          itemCount = itemsInCartCount,
          onCheckoutClick = {
            activeTab = "Sacola"
          }
        )
      }

      // Profile Dialogue / Overlay
      if (showProfileDialog) {
        ProfileOverlay(
          onClose = { showProfileDialog = false }
        )
      }

      // Signature Dish Details / Bottom Panel Overlay
      AnimatedVisibility(
        visible = selectedRestaurant != null,
        enter = slideInVertically(initialOffsetY = { h -> h }) + fadeIn(),
        exit = slideOutVertically(targetOffsetY = { h -> h }) + fadeOut(),
        modifier = Modifier.fillMaxSize()
      ) {
        selectedRestaurant?.let { restaurant ->
          RestaurantDetailsOverlay(
            restaurant = restaurant,
            onClose = { selectedRestaurant = null },
            onAddDishToCart = {
              itemsInCartCount++
            }
          )
        }
      }
    }
  }
}

@Composable
fun HomeHeader(
  onProfileClick: () -> Unit,
  onLocationClick: () -> Unit
) {
  Row(
    modifier = Modifier
      .fillMaxWidth()
      .padding(horizontal = 20.dp, vertical = 16.dp),
    horizontalArrangement = Arrangement.SpaceBetween,
    verticalAlignment = Alignment.CenterVertically
  ) {
    Column {
      Text(
        text = "Uni eats",
        style = MaterialTheme.typography.displayMedium.copy(
          color = MaterialTheme.colorScheme.primary,
          fontWeight = FontWeight.Light,
          fontSize = 26.sp,
          letterSpacing = 1.sp
        ),
        modifier = Modifier.testTag("app_logo")
      )
      
      // Location Indicator
      Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
          .padding(top = 4.dp)
          .clickable { onLocationClick() }
          .testTag("location_selector")
      ) {
        Icon(
          imageVector = Icons.Default.LocationOn,
          contentDescription = "Localização",
          tint = MaterialTheme.colorScheme.primary,
          modifier = Modifier.size(14.dp)
        )
        Spacer(modifier = Modifier.width(4.dp))
        Text(
          text = "Jardins, São Paulo",
          style = MaterialTheme.typography.bodySmall.copy(
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.8f),
            fontWeight = FontWeight.Medium
          )
        )
        Icon(
          imageVector = Icons.Default.KeyboardArrowDown,
          contentDescription = "Alterar localização",
          tint = MaterialTheme.colorScheme.primary,
          modifier = Modifier.size(14.dp)
        )
      }
    }

    // Profile Avatar (Discrete Luxury Circle)
    Box(
      modifier = Modifier
        .size(42.dp)
        .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.4f), CircleShape)
        .padding(2.dp)
        .clip(CircleShape)
        .background(MaterialTheme.colorScheme.surfaceVariant)
        .clickable { onProfileClick() }
        .testTag("profile_button"),
      contentAlignment = Alignment.Center
    ) {
      Icon(
        imageVector = Icons.Default.Person,
        contentDescription = "Perfil do Cliente",
        tint = MaterialTheme.colorScheme.primary,
        modifier = Modifier.size(22.dp)
      )
    }
  }
}

@Composable
fun SearchBar(
  query: String,
  onQueryChange: (String) -> Unit
) {
  var isFocused by remember { mutableStateOf(false) }

  Box(
    modifier = Modifier
      .fillMaxWidth()
      .padding(horizontal = 20.dp, vertical = 8.dp)
  ) {
    OutlinedTextField(
      value = query,
      onValueChange = onQueryChange,
      modifier = Modifier
        .fillMaxWidth()
        .height(50.dp)
        .testTag("search_bar"),
      placeholder = {
        Text(
          text = "Pesquisar restaurantes, pratos ou alta gastronomia...",
          style = MaterialTheme.typography.bodyMedium.copy(
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.4f)
          )
        )
      },
      leadingIcon = {
        Icon(
          imageVector = Icons.Default.Search,
          contentDescription = "Search Icon",
          tint = if (isFocused) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f),
          modifier = Modifier.size(18.dp)
        )
      },
      colors = OutlinedTextFieldDefaults.colors(
        focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.6f),
        unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
        focusedBorderColor = MaterialTheme.colorScheme.primary,
        unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
        focusedTextColor = MaterialTheme.colorScheme.onBackground,
        unfocusedTextColor = MaterialTheme.colorScheme.onBackground
      ),
      shape = RoundedCornerShape(25.dp), // Extremely soft modern rounded style
      singleLine = true,
      textStyle = MaterialTheme.typography.bodyMedium
    )
  }
}

@Composable
fun HighlightsCarousel(
  onHighlightClick: () -> Unit
) {
  Column(
    modifier = Modifier
      .fillMaxWidth()
      .padding(top = 16.dp)
  ) {
    Row(
      modifier = Modifier
        .fillMaxWidth()
        .padding(horizontal = 20.dp, vertical = 8.dp),
      horizontalArrangement = Arrangement.SpaceBetween,
      verticalAlignment = Alignment.CenterVertically
    ) {
      Text(
        text = "Destaques da Semana",
        style = MaterialTheme.typography.titleLarge.copy(
          color = MaterialTheme.colorScheme.onBackground,
          fontWeight = FontWeight.SemiBold
        )
      )
      Text(
        text = "Ver Todos",
        style = MaterialTheme.typography.labelMedium.copy(
          color = MaterialTheme.colorScheme.primary,
          fontWeight = FontWeight.Medium
        ),
        modifier = Modifier.clickable { /* Simulate expand */ }
      )
    }

    // Horizontal Scrollable Container
    Row(
      modifier = Modifier
        .fillMaxWidth()
        .horizontalScroll(rememberScrollState())
        .padding(horizontal = 20.dp, vertical = 4.dp),
      horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
      // Large Luxury Card
      Card(
        modifier = Modifier
          .width(320.dp)
          .height(180.dp)
          .clip(RoundedCornerShape(16.dp))
          .clickable { onHighlightClick() }
          .testTag("highlight_card"),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
      ) {
        Box(modifier = Modifier.fillMaxSize()) {
          // Banner Image (Using generated luxe banner asset)
          Image(
            painter = painterResource(id = R.drawable.img_luxe_banner_1783374585687),
            contentDescription = "Destaque Gourmet",
            modifier = Modifier.fillMaxSize(),
            contentScale = ContentScale.Crop
          )

          // Dark luxury radial overlay gradient to make typography pop
          Box(
            modifier = Modifier
              .fillMaxSize()
              .background(
                Brush.verticalGradient(
                  colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.85f)),
                  startY = 100f
                )
              )
          )

          // Premium Typography layout on card
          Column(
            modifier = Modifier
              .align(Alignment.BottomStart)
              .padding(16.dp)
          ) {
            Box(
              modifier = Modifier
                .background(MaterialTheme.colorScheme.primary, RoundedCornerShape(4.dp))
                .padding(horizontal = 8.dp, vertical = 2.dp)
            ) {
              Text(
                text = "CURADORIA",
                style = MaterialTheme.typography.labelSmall.copy(
                  color = MaterialTheme.colorScheme.onPrimary,
                  fontWeight = FontWeight.Bold,
                  letterSpacing = 1.sp
                )
              )
            }
            Spacer(modifier = Modifier.height(8.dp))
            Text(
              text = "Michelin em Casa",
              style = MaterialTheme.typography.titleMedium.copy(
                color = Color.White,
                fontWeight = FontWeight.Bold
              )
            )
            Text(
              text = "Experimente menus exclusivos criados por chefs estrelados.",
              style = MaterialTheme.typography.bodySmall.copy(
                color = Color.White.copy(alpha = 0.75f)
              ),
              maxLines = 1,
              overflow = TextOverflow.Ellipsis
            )
          }
        }
      }

      // Secondary Decorative Banner Card
      Card(
        modifier = Modifier
          .width(260.dp)
          .height(180.dp)
          .clip(RoundedCornerShape(16.dp))
          .clickable { onHighlightClick() },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
      ) {
        Box(
          modifier = Modifier
            .fillMaxSize()
            .background(
              Brush.linearGradient(
                colors = listOf(MaterialTheme.colorScheme.surface, MaterialTheme.colorScheme.surfaceVariant)
              )
            )
            .border(
              BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.2f)),
              RoundedCornerShape(16.dp)
            )
            .padding(18.dp)
        ) {
          Column(
            modifier = Modifier.fillMaxHeight(),
            verticalArrangement = Arrangement.SpaceBetween
          ) {
            Icon(
              imageVector = Icons.Default.LocalMall,
              contentDescription = "Selo de Ouro",
              tint = MaterialTheme.colorScheme.primary,
              modifier = Modifier.size(32.dp)
            )

            Column {
              Text(
                text = "Club Uni Privé",
                style = MaterialTheme.typography.titleMedium.copy(
                  color = MaterialTheme.colorScheme.onBackground,
                  fontWeight = FontWeight.Bold
                )
              )
              Spacer(modifier = Modifier.height(4.dp))
              Text(
                text = "Taxa de entrega isenta e mimos de cortesia de chefs em todos os pedidos.",
                style = MaterialTheme.typography.bodySmall.copy(
                  color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
                ),
                maxLines = 3,
                overflow = TextOverflow.Ellipsis
              )
            }
          }
        }
      }
    }
  }
}

@Composable
fun QuickFilters(
  selectedCategory: String,
  onCategorySelected: (String) -> Unit
) {
  val categories = listOf("Todos", "Gourmet", "Massas", "Hambúrguer", "Pizza", "Pastel", "Experiências")
  val categoryIcons = listOf("🌟", "🍣", "🍝", "🍔", "🍕", "🥟", "🍷") // Luxury minimalist representation

  Column(
    modifier = Modifier
      .fillMaxWidth()
      .padding(top = 20.dp)
  ) {
    Text(
      text = "Categorias Premium",
      style = MaterialTheme.typography.titleMedium.copy(
        color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.7f),
        fontWeight = FontWeight.SemiBold,
        letterSpacing = 0.5.sp
      ),
      modifier = Modifier.padding(horizontal = 20.dp, vertical = 8.dp)
    )

    Row(
      modifier = Modifier
        .fillMaxWidth()
        .horizontalScroll(rememberScrollState())
        .padding(horizontal = 20.dp, vertical = 4.dp),
      horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
      categories.forEachIndexed { index, category ->
        val isSelected = selectedCategory == category
        Row(
          modifier = Modifier
            .border(
              BorderStroke(
                width = 1.dp,
                color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)
              ),
              shape = RoundedCornerShape(20.dp)
            )
            .background(
              color = if (isSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.15f) else Color.Transparent,
              shape = RoundedCornerShape(20.dp)
            )
            .clickable { onCategorySelected(category) }
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .testTag("filter_$category"),
          verticalAlignment = Alignment.CenterVertically
        ) {
          Text(
            text = categoryIcons[index],
            modifier = Modifier.padding(end = 6.dp)
          )
          Text(
            text = category,
            style = MaterialTheme.typography.bodyMedium.copy(
              color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onBackground,
              fontWeight = if (isSelected) FontWeight.SemiBold else FontWeight.Normal
            )
          )
        }
      }
    }
  }
}

@Composable
fun RestaurantCard(
  restaurant: Restaurant,
  onClick: () -> Unit
) {
  Card(
    modifier = Modifier
      .fillMaxWidth()
      .padding(horizontal = 20.dp, vertical = 10.dp)
      .clickable { onClick() }
      .testTag("restaurant_card_${restaurant.id}"),
    shape = RoundedCornerShape(16.dp),
    colors = CardDefaults.cardColors(
      containerColor = MaterialTheme.colorScheme.surface
    ),
    border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.15f))
  ) {
    Column {
      // Cover Image (Using unique generated restaurant illustrations)
      Box(
        modifier = Modifier
          .fillMaxWidth()
          .height(160.dp)
      ) {
        Image(
          painter = painterResource(id = restaurant.imageResId),
          contentDescription = restaurant.name,
          modifier = Modifier.fillMaxSize(),
          contentScale = ContentScale.Crop
        )

        // Luxury gradient top-bottom on image
        Box(
          modifier = Modifier
            .fillMaxSize()
            .background(
              Brush.verticalGradient(
                colors = listOf(Color.Black.copy(alpha = 0.4f), Color.Transparent, Color.Black.copy(alpha = 0.5f))
              )
            )
        )

        // Tag Exclusivo / Michelin Guide
        Box(
          modifier = Modifier
            .align(Alignment.TopStart)
            .padding(12.dp)
            .background(Color.Black.copy(alpha = 0.75f), RoundedCornerShape(4.dp))
            .border(0.5.dp, MaterialTheme.colorScheme.primary, RoundedCornerShape(4.dp))
            .padding(horizontal = 8.dp, vertical = 4.dp)
        ) {
          Text(
            text = restaurant.tag,
            style = MaterialTheme.typography.labelSmall.copy(
              color = MaterialTheme.colorScheme.primary,
              fontWeight = FontWeight.Bold,
              letterSpacing = 0.5.sp
            )
          )
        }

        // Delivery time badge bottom right
        Box(
          modifier = Modifier
            .align(Alignment.BottomEnd)
            .padding(12.dp)
            .background(Color.Black.copy(alpha = 0.75f), RoundedCornerShape(12.dp))
            .padding(horizontal = 10.dp, vertical = 4.dp)
        ) {
          Text(
            text = restaurant.deliveryTime,
            style = MaterialTheme.typography.labelSmall.copy(
              color = Color.White,
              fontWeight = FontWeight.Medium
            )
          )
        }
      }

      // Details block
      Column(
        modifier = Modifier.padding(16.dp)
      ) {
        Row(
          modifier = Modifier.fillMaxWidth(),
          horizontalArrangement = Arrangement.SpaceBetween,
          verticalAlignment = Alignment.CenterVertically
        ) {
          Text(
            text = restaurant.name,
            style = MaterialTheme.typography.titleLarge.copy(
              fontWeight = FontWeight.Bold,
              color = MaterialTheme.colorScheme.onBackground
            )
          )

          // Rating badge
          Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
              .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.1f), RoundedCornerShape(6.dp))
              .padding(horizontal = 6.dp, vertical = 3.dp)
          ) {
            Icon(
              imageVector = Icons.Default.Star,
              contentDescription = "Nota",
              tint = MaterialTheme.colorScheme.primary,
              modifier = Modifier.size(12.dp)
            )
            Spacer(modifier = Modifier.width(4.dp))
            Text(
              text = restaurant.rating.toString(),
              style = MaterialTheme.typography.labelMedium.copy(
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold
              )
            )
          }
        }

        Spacer(modifier = Modifier.height(4.dp))

        // Subtitle containing details
        Row(
          verticalAlignment = Alignment.CenterVertically,
          modifier = Modifier.fillMaxWidth()
        ) {
          Text(
            text = restaurant.category,
            style = MaterialTheme.typography.bodyMedium.copy(
              color = MaterialTheme.colorScheme.primary,
              fontWeight = FontWeight.Medium
            )
          )
          Text(
            text = " • ",
            style = MaterialTheme.typography.bodyMedium.copy(
              color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.3f)
            )
          )
          Text(
            text = restaurant.distance,
            style = MaterialTheme.typography.bodyMedium.copy(
              color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
            )
          )
          Text(
            text = " • Entrega: ${restaurant.deliveryFee}",
            style = MaterialTheme.typography.bodyMedium.copy(
              color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
            )
          )
        }
      }
    }
  }
}

@Composable
fun FloatingCartButton(
  itemCount: Int,
  onCheckoutClick: () -> Unit
) {
  var showOrderCompleteMessage by remember { mutableStateOf(false) }

  LaunchedEffect(showOrderCompleteMessage) {
    if (showOrderCompleteMessage) {
      delay(3000)
      showOrderCompleteMessage = false
    }
  }

  Column(horizontalAlignment = Alignment.CenterHorizontally) {
    if (showOrderCompleteMessage) {
      Box(
        modifier = Modifier
          .background(MaterialTheme.colorScheme.primary, RoundedCornerShape(8.dp))
          .padding(horizontal = 16.dp, vertical = 8.dp)
          .padding(bottom = 8.dp)
      ) {
        Text(
          text = "🥂 Pedido gourmet enviado com sucesso!",
          style = MaterialTheme.typography.bodyMedium.copy(
            color = MaterialTheme.colorScheme.onPrimary,
            fontWeight = FontWeight.Bold
          )
        )
      }
    }

    Row(
      modifier = Modifier
        .fillMaxWidth()
        .height(56.dp)
        .background(Color.Black, RoundedCornerShape(28.dp))
        .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.6f), RoundedCornerShape(28.dp))
        .clickable {
          showOrderCompleteMessage = true
          onCheckoutClick()
        }
        .padding(horizontal = 20.dp),
      horizontalArrangement = Arrangement.SpaceBetween,
      verticalAlignment = Alignment.CenterVertically
    ) {
      Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
          modifier = Modifier
            .size(24.dp)
            .background(MaterialTheme.colorScheme.primary, CircleShape),
          contentAlignment = Alignment.Center
        ) {
          Text(
            text = itemCount.toString(),
            style = MaterialTheme.typography.labelSmall.copy(
              color = MaterialTheme.colorScheme.onPrimary,
              fontWeight = FontWeight.Bold
            )
          )
        }
        Spacer(modifier = Modifier.width(10.dp))
        Text(
          text = "Sacola Uni eats",
          style = MaterialTheme.typography.titleMedium.copy(
            color = Color.White,
            fontWeight = FontWeight.SemiBold
          )
        )
      }

      Text(
        text = "RESERVAR & PEDIR ➔",
        style = MaterialTheme.typography.labelLarge.copy(
          color = MaterialTheme.colorScheme.primary,
          fontWeight = FontWeight.Bold,
          letterSpacing = 0.5.sp
        )
      )
    }
  }
}

@Composable
fun RestaurantDetailsOverlay(
  restaurant: Restaurant,
  onClose: () -> Unit,
  onAddDishToCart: () -> Unit
) {
  Box(
    modifier = Modifier
      .fillMaxSize()
      .background(Color.Black.copy(alpha = 0.75f))
      .clickable { onClose() } // Tap outside to dismiss
  ) {
    // Elegant slide up sheet
    Column(
      modifier = Modifier
        .fillMaxWidth()
        .fillMaxHeight(0.85f)
        .align(Alignment.BottomCenter)
        .clickable(enabled = false) {} // Prevent click-throughs
        .background(
          MaterialTheme.colorScheme.surface,
          RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)
        )
        .border(
          BorderStroke(1.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)),
          RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)
        )
    ) {
      // Top Drag / Indicator Handle
      Box(
        modifier = Modifier
          .fillMaxWidth()
          .padding(vertical = 12.dp),
        contentAlignment = Alignment.Center
      ) {
        Box(
          modifier = Modifier
            .width(40.dp)
            .height(4.dp)
            .background(MaterialTheme.colorScheme.onSurface.copy(alpha = 0.15f), RoundedCornerShape(2.dp))
        )
      }

      // Close and header
      Row(
        modifier = Modifier
          .fillMaxWidth()
          .padding(horizontal = 24.dp, vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Text(
          text = "Menu de Assinatura",
          style = MaterialTheme.typography.titleLarge.copy(
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.Bold
          )
        )

        Icon(
          imageVector = Icons.Default.Close,
          contentDescription = "Fechar",
          tint = MaterialTheme.colorScheme.onSurface,
          modifier = Modifier
            .size(24.dp)
            .clickable { onClose() }
            .testTag("close_details_button")
        )
      }

      Spacer(modifier = Modifier.height(12.dp))

      // Content Column containing signature dishes
      LazyColumn(
        modifier = Modifier
          .weight(1f)
          .fillMaxWidth(),
        contentPadding = PaddingValues(horizontal = 24.dp, vertical = 8.dp)
      ) {
        item {
          Text(
            text = restaurant.name,
            style = MaterialTheme.typography.displaySmall.copy(
              color = MaterialTheme.colorScheme.onSurface,
              fontWeight = FontWeight.Bold
            )
          )
          Spacer(modifier = Modifier.height(4.dp))
          Text(
            text = "Curadoria exclusiva preparada sob demanda pelos chefs mais renomados.",
            style = MaterialTheme.typography.bodyMedium.copy(
              color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
            )
          )
          Spacer(modifier = Modifier.height(24.dp))
        }

        items(restaurant.signatureDishes) { dish ->
          var isAddedSuccessfully by remember { mutableStateOf(false) }

          LaunchedEffect(isAddedSuccessfully) {
            if (isAddedSuccessfully) {
              delay(1500)
              isAddedSuccessfully = false
            }
          }

          Column(
            modifier = Modifier
              .fillMaxWidth()
              .padding(vertical = 12.dp)
              .border(
                BorderStroke(0.5.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)),
                RoundedCornerShape(12.dp)
              )
              .background(MaterialTheme.colorScheme.background.copy(alpha = 0.3f), RoundedCornerShape(12.dp))
              .padding(16.dp)
          ) {
            Row(
              modifier = Modifier.fillMaxWidth(),
              horizontalArrangement = Arrangement.SpaceBetween,
              verticalAlignment = Alignment.Top
            ) {
              Column(modifier = Modifier.weight(1f)) {
                Text(
                  text = dish.name,
                  style = MaterialTheme.typography.titleMedium.copy(
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                  )
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                  text = dish.description,
                  style = MaterialTheme.typography.bodyMedium.copy(
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                  ),
                  maxLines = 3,
                  overflow = TextOverflow.Ellipsis
                )
              }

              Spacer(modifier = Modifier.width(16.dp))

              Text(
                text = dish.price,
                style = MaterialTheme.typography.titleMedium.copy(
                  color = MaterialTheme.colorScheme.primary,
                  fontWeight = FontWeight.Bold
                )
              )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Add button
            Button(
              onClick = {
                onAddDishToCart()
                isAddedSuccessfully = true
              },
              modifier = Modifier
                .align(Alignment.End)
                .height(36.dp),
              colors = ButtonDefaults.buttonColors(
                containerColor = if (isAddedSuccessfully) Color(0xFF4CAF50) else MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary
              ),
              shape = RoundedCornerShape(18.dp),
              contentPadding = PaddingValues(horizontal = 16.dp, vertical = 0.dp)
            ) {
              Text(
                text = if (isAddedSuccessfully) "✓ Adicionado" else "Adicionar à Sacola",
                style = MaterialTheme.typography.labelMedium.copy(
                  fontWeight = FontWeight.Bold
                )
              )
            }
          }
        }
      }

      // Bottom disclaimer / styling
      Box(
        modifier = Modifier
          .fillMaxWidth()
          .background(MaterialTheme.colorScheme.background)
          .padding(horizontal = 24.dp, vertical = 16.dp)
          .navigationBarsPadding(),
        contentAlignment = Alignment.Center
      ) {
        Text(
          text = "🥂 Uni eats Privé: Reservas sujeitas à lotação do chef.",
          style = MaterialTheme.typography.bodySmall.copy(
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.Medium
          )
        )
      }
    }
  }
}

@Composable
fun ProfileOverlay(
  onClose: () -> Unit
) {
  Box(
    modifier = Modifier
      .fillMaxSize()
      .background(Color.Black.copy(alpha = 0.8f))
      .clickable { onClose() },
    contentAlignment = Alignment.Center
  ) {
    Column(
      modifier = Modifier
        .widthIn(max = 320.dp)
        .fillMaxWidth(0.85f)
        .clickable(enabled = false) {}
        .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(24.dp))
        .border(BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.3f)), RoundedCornerShape(24.dp))
        .padding(24.dp),
      horizontalAlignment = Alignment.CenterHorizontally
    ) {
      // Avatar Logo
      Box(
        modifier = Modifier
          .size(72.dp)
          .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f), CircleShape)
          .border(1.5.dp, MaterialTheme.colorScheme.primary, CircleShape),
        contentAlignment = Alignment.Center
      ) {
        Icon(
          imageVector = Icons.Default.Person,
          contentDescription = "Avatar grande",
          tint = MaterialTheme.colorScheme.primary,
          modifier = Modifier.size(36.dp)
        )
      }

      Spacer(modifier = Modifier.height(16.dp))

      Text(
        text = "Membro Select",
        style = MaterialTheme.typography.titleLarge.copy(
          color = MaterialTheme.colorScheme.primary,
          fontWeight = FontWeight.Bold,
          letterSpacing = 1.sp
        )
      )

      Text(
        text = "aquilaa043@gmail.com",
        style = MaterialTheme.typography.bodyMedium.copy(
          color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
        )
      )

      Spacer(modifier = Modifier.height(20.dp))

      Box(
        modifier = Modifier
          .fillMaxWidth()
          .background(MaterialTheme.colorScheme.background, RoundedCornerShape(12.dp))
          .padding(12.dp)
      ) {
        Column {
          Text(
            text = "🏅 Status de Fidelidade: Black",
            style = MaterialTheme.typography.titleSmall.copy(
              color = MaterialTheme.colorScheme.onSurface,
              fontWeight = FontWeight.Bold
            )
          )
          Spacer(modifier = Modifier.height(4.dp))
          Text(
            text = "Você tem direito a concierge gourmet prioritário e entrega expressa isenta.",
            style = MaterialTheme.typography.bodySmall.copy(
              color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
            )
          )
        }
      }

      Spacer(modifier = Modifier.height(24.dp))

      Button(
        onClick = onClose,
        modifier = Modifier
          .fillMaxWidth()
          .height(44.dp),
        colors = ButtonDefaults.buttonColors(
          containerColor = MaterialTheme.colorScheme.primary,
          contentColor = MaterialTheme.colorScheme.onPrimary
        ),
        shape = RoundedCornerShape(22.dp)
      ) {
        Text(
          text = "Fechar",
          style = MaterialTheme.typography.labelLarge.copy(
            fontWeight = FontWeight.Bold
          )
        )
      }
    }
  }
}

@Composable
fun LuxuryBottomNavigation(
  activeTab: String,
  onTabSelected: (String) -> Unit
) {
  Row(
    modifier = Modifier
      .fillMaxWidth()
      .background(MaterialTheme.colorScheme.surface)
      .border(
        width = 1.dp,
        color = MaterialTheme.colorScheme.primary.copy(alpha = 0.12f),
        shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp)
      )
      .navigationBarsPadding()
      .padding(vertical = 12.dp, horizontal = 24.dp),
    horizontalArrangement = Arrangement.SpaceBetween,
    verticalAlignment = Alignment.CenterVertically
  ) {
    val items = listOf(
      Triple("Início", Icons.Default.Home, "Início"),
      Triple("Explorar", Icons.Default.Search, "Explorar"),
      Triple("Chef", Icons.Default.Settings, "Chef"),
      Triple("Rastrear", Icons.Default.LocalShipping, "Rastrear"),
      Triple("Sacola", Icons.Default.LocalMall, "Sacola"),
      Triple("Perfil", Icons.Default.Person, "Perfil")
    )

    items.forEach { (tabName, icon, label) ->
      val isSelected = activeTab == tabName
      val color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
      
      Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
          .clickable { onTabSelected(tabName) }
          .padding(8.dp)
          .testTag("nav_tab_$tabName"),
        verticalArrangement = Arrangement.Center
      ) {
        Icon(
          imageVector = icon,
          contentDescription = label,
          tint = color,
          modifier = Modifier.size(24.dp)
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
          text = label.uppercase(),
          style = MaterialTheme.typography.labelSmall.copy(
            color = color,
            fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
            fontSize = 9.sp,
            letterSpacing = 1.5.sp
          )
        )
      }
    }
  }
}

@Composable
fun RastrearScreenContent(
  deliveryState: String,
  journeyStep: Int,
  simulationProgress: Float,
  riderLatitude: Double,
  riderLongitude: Double,
  selectedCityType: TipoCidade,
  orderList: List<Order>,
  onNavigateToExplore: () -> Unit
) {
  var isExpandedFees by remember { mutableStateOf(false) }
  var showChatDialog by remember { mutableStateOf(false) }
  var chatMessageText by remember { mutableStateOf("") }
  val chatHistory = remember {
    androidx.compose.runtime.mutableStateListOf<Pair<String, String>>(
      "Rider" to "Olá! Seu pedido já está sendo preparado e vou cuidar da sua entrega rápida.",
      "Rider" to "Assim que coletar na cozinha premium, aviso você por aqui! 🏍️"
    )
  }

  val activeOrder = orderList.lastOrNull()
  val hasActiveOrder = activeOrder != null && deliveryState != "idle"

  // Se não houver pedido ativo, exibe o estado vazio premium
  if (!hasActiveOrder) {
    Box(
      modifier = Modifier
        .fillMaxSize()
        .padding(24.dp),
      contentAlignment = Alignment.Center
    ) {
      Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxWidth()
      ) {
        Text(
          text = "📦",
          style = MaterialTheme.typography.displayLarge.copy(fontSize = 72.sp),
          modifier = Modifier.padding(bottom = 24.dp)
        )
        Text(
          text = "NENHUM PEDIDO EM ANDAMENTO",
          style = MaterialTheme.typography.titleMedium.copy(
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.Bold,
            letterSpacing = 1.5.sp
          ),
          textAlign = TextAlign.Center
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(
          text = "Selecione pratos finos em nosso cardápio de alta gastronomia para simular e acompanhar o rastreamento em tempo real com GPS.",
          style = MaterialTheme.typography.bodyMedium.copy(
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f),
            lineHeight = 22.sp
          ),
          textAlign = TextAlign.Center,
          modifier = Modifier.padding(horizontal = 16.dp)
        )
        Spacer(modifier = Modifier.height(32.dp))
        Button(
          onClick = onNavigateToExplore,
          modifier = Modifier
            .fillMaxWidth(0.8f)
            .height(50.dp),
          colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary),
          shape = RoundedCornerShape(25.dp)
        ) {
          Text(
            text = "VER CARDÁPIO DO HUB",
            style = MaterialTheme.typography.labelMedium.copy(
              fontWeight = FontWeight.Bold,
              letterSpacing = 1.sp,
              color = Color.Black
            )
          )
        }
      }
    }
    return
  }

  // Se houver pedido ativo, exibe o painel de rastreamento completo
  LazyColumn(
    modifier = Modifier
      .fillMaxSize()
      .padding(horizontal = 20.dp),
    contentPadding = PaddingValues(top = 16.dp, bottom = 100.dp)
  ) {
    // HEADER PREMIUM
    item {
      Row(
        modifier = Modifier
          .fillMaxWidth()
          .padding(vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Column {
          Text(
            text = "Rastreamento do Pedido",
            style = MaterialTheme.typography.titleLarge.copy(
              fontWeight = FontWeight.Light,
              letterSpacing = 0.5.sp,
              color = MaterialTheme.colorScheme.primary
            )
          )
          Spacer(modifier = Modifier.height(4.dp))
          Text(
            text = "PEDIDO #${activeOrder?.id?.replace("#", "") ?: "5812"} • ${activeOrder?.deliveryType ?: "Uni eats Signature"}",
            style = MaterialTheme.typography.labelSmall.copy(
              color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
              fontWeight = FontWeight.Bold,
              letterSpacing = 1.sp
            )
          )
        }
        Box(
          modifier = Modifier
            .clip(RoundedCornerShape(12.dp))
            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.1f))
            .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.25f), RoundedCornerShape(12.dp))
            .padding(horizontal = 12.dp, vertical = 6.dp)
        ) {
          Text(
            text = if (deliveryState == "offered") "CONFIRMANDO..."
                   else if (journeyStep == 1) "EM PREPARO"
                   else if (journeyStep == 2) "PRONTO"
                   else if (journeyStep == 3) "EM ROTA"
                   else "ENTREGUE",
            style = MaterialTheme.typography.labelSmall.copy(
              color = MaterialTheme.colorScheme.primary,
              fontWeight = FontWeight.Bold,
              letterSpacing = 1.sp
            )
          )
        }
      }
      Spacer(modifier = Modifier.height(16.dp))
    }

    // MAPA PREMIUM COM GPS DINÂMICO
    item {
      Card(
        modifier = Modifier
          .fillMaxWidth()
          .height(220.dp)
          .padding(vertical = 8.dp),
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
      ) {
        Box(modifier = Modifier.fillMaxSize()) {
          // Desenhando o mapa minimalista premium no Canvas
          Canvas(modifier = Modifier.fillMaxSize()) {
            drawRect(color = Color(0xFF141414))

            // Linhas de ruas discretas (Grid Urbano)
            val streetColor = Color(0xFF1F1F1F)
            val streetWidth = 14f

            // Ruas Horizontais
            drawLine(color = streetColor, start = Offset(0f, 60f), end = Offset(size.width, 60f), strokeWidth = streetWidth)
            drawLine(color = streetColor, start = Offset(0f, 160f), end = Offset(size.width, 160f), strokeWidth = streetWidth)
            drawLine(color = streetColor, start = Offset(0f, 280f), end = Offset(size.width, 280f), strokeWidth = streetWidth)

            // Ruas Verticais
            drawLine(color = streetColor, start = Offset(100f, 0f), end = Offset(100f, size.height), strokeWidth = streetWidth)
            drawLine(color = streetColor, start = Offset(300f, 0f), end = Offset(300f, size.height), strokeWidth = streetWidth)
            drawLine(color = streetColor, start = Offset(520f, 0f), end = Offset(520f, size.height), strokeWidth = streetWidth)

            // Rota Ativa (Linha de Destaque Ouro Velho)
            val startX = 140f
            val startY = 180f
            val endX = 480f
            val endY = 80f

            // Rota completa em background fosco
            drawLine(
              color = Color(0xFFD4AF37).copy(alpha = 0.25f),
              start = Offset(startX, startY),
              end = Offset(endX, endY),
              strokeWidth = 5f
            )

            // Rota percorrida dinamicamente baseada no progresso (se estiver a caminho)
            if (journeyStep == 3) {
              val currentX = startX + (endX - startX) * simulationProgress
              val currentY = startY + (endY - startY) * simulationProgress

              drawLine(
                color = Color(0xFFD4AF37),
                start = Offset(startX, startY),
                end = Offset(currentX, currentY),
                strokeWidth = 5f
              )
            }
          }

          // Nós Estáticos no Mapa (Restaurante e Cliente)
          // 1. Restaurante (Início)
          Box(
            modifier = Modifier
              .offset(x = 35.dp, y = 80.dp)
              .size(24.dp)
              .clip(CircleShape)
              .background(Color.Black)
              .border(1.5.dp, MaterialTheme.colorScheme.primary, CircleShape),
            contentAlignment = Alignment.Center
          ) {
            Text("🍳", fontSize = 11.sp)
          }
          Text(
            text = "UniEats Signature",
            color = Color.White.copy(alpha = 0.7f),
            fontSize = 9.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.offset(x = 15.dp, y = 108.dp)
          )

          // 2. Cliente (Destino)
          Box(
            modifier = Modifier
              .offset(x = 225.dp, y = 30.dp)
              .size(24.dp)
              .clip(CircleShape)
              .background(Color.Black)
              .border(1.5.dp, Color(0xFF4CAF50), CircleShape),
            contentAlignment = Alignment.Center
          ) {
            Text("🏠", fontSize = 11.sp)
          }
          Text(
            text = "Seu Endereço",
            color = Color.White.copy(alpha = 0.7f),
            fontSize = 9.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.offset(x = 212.dp, y = 58.dp)
          )

          // Marcador do Entregador Dinâmico se estiver aceito
          if (deliveryState == "accepted") {
            val startX = 35f // 35.dp
            val startY = 80f // 80.dp
            val endX = 225f  // 225.dp
            val endY = 30f   // 30.dp

            val riderX = when (journeyStep) {
              1 -> startX - (15f * (1.0f - simulationProgress)) // Simulando aproximação do motoboy
              2 -> startX
              3 -> startX + (endX - startX) * simulationProgress
              else -> endX
            }

            val riderY = when (journeyStep) {
              1 -> startY + (20f * (1.0f - simulationProgress))
              2 -> startY
              3 -> startY + (endY - startY) * simulationProgress
              else -> endY
            }

            Box(
              modifier = Modifier
                .offset(x = riderX.dp, y = riderY.dp)
                .size(30.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.primary)
                .border(2.dp, Color.Black, CircleShape),
              contentAlignment = Alignment.Center
            ) {
              Text("🏍️", fontSize = 14.sp)
            }
          }
        }
      }
      Spacer(modifier = Modifier.height(16.dp))
    }

    // MINI-CARD DO ENTREGADOR E SUPORTE
    item {
      Card(
        modifier = Modifier
          .fillMaxWidth()
          .padding(vertical = 8.dp),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.1f))
      ) {
        Row(
          modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
          verticalAlignment = Alignment.CenterVertically,
          horizontalArrangement = Arrangement.SpaceBetween
        ) {
          Row(verticalAlignment = Alignment.CenterVertically) {
            // Placeholder sofisticado de foto de perfil
            Box(
              modifier = Modifier
                .size(48.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
                .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.3f), CircleShape),
              contentAlignment = Alignment.Center
            ) {
              Text(
                text = "MN",
                style = MaterialTheme.typography.titleMedium.copy(
                  color = MaterialTheme.colorScheme.primary,
                  fontWeight = FontWeight.Bold
                )
              )
            }
            Spacer(modifier = Modifier.width(14.dp))
            Column {
              Text(
                text = "Maurício Neves",
                style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
              )
              Text(
                text = "Entregador Parceiro Premium",
                style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
              )
              Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(top = 2.dp)
              ) {
                Text(text = "⭐ 4.9", style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold))
                Spacer(modifier = Modifier.width(6.dp))
                Text(text = "• 1.242 corridas", style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)))
              }
            }
          }

          Row {
            // Botão de Chat
            IconButton(
              onClick = { showChatDialog = true },
              modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            ) {
              Icon(
                imageVector = Icons.Default.Chat,
                contentDescription = "Chat com Entregador",
                tint = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(18.dp)
              )
            }
            Spacer(modifier = Modifier.width(8.dp))
            // Botão de Ligação
            IconButton(
              onClick = { /* Ligação simulada */ },
              modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
            ) {
              Icon(
                imageVector = Icons.Default.Phone,
                contentDescription = "Ligar para Entregador",
                tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                modifier = Modifier.size(18.dp)
              )
            }
          }
        }
      }
      Spacer(modifier = Modifier.height(16.dp))
    }

    // LINHA DO TEMPO (STEPPER MINIMALISTA)
    item {
      Card(
        modifier = Modifier
          .fillMaxWidth()
          .padding(vertical = 8.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.1f))
      ) {
        Column(modifier = Modifier.padding(20.dp)) {
          Text(
            text = "Evolução do Pedido",
            style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
            modifier = Modifier.padding(bottom = 20.dp)
          )

          // Step 1: Pedido Confirmado
          val step1Completed = deliveryState == "offered" || deliveryState == "accepted"
          val step1Active = deliveryState == "offered"
          TrackingStepItem(
            stepNumber = 1,
            title = "Pedido Confirmado",
            description = "Seu pedido gastronômico foi integrado e aprovado.",
            isActive = step1Active,
            isCompleted = step1Completed && !step1Active,
            showLine = true
          )

          // Step 2: Em Preparo
          val step2Completed = deliveryState == "accepted" && journeyStep > 1
          val step2Active = deliveryState == "accepted" && journeyStep == 1
          TrackingStepItem(
            stepNumber = 2,
            title = "Em Preparo",
            description = "O Chef gourmet está preparando sua seleção especial.",
            isActive = step2Active,
            isCompleted = step2Completed,
            showLine = true
          )

          // Step 3: Pronto para Coleta
          val step3Completed = deliveryState == "accepted" && journeyStep > 2
          val step3Active = deliveryState == "accepted" && journeyStep == 2
          TrackingStepItem(
            stepNumber = 3,
            title = "Pronto para Coleta",
            description = "Seu pedido foi embalado sob proteção térmica.",
            isActive = step3Active,
            isCompleted = step3Completed,
            showLine = true
          )

          // Step 4: A Caminho
          val step4Completed = deliveryState == "accepted" && journeyStep > 3
          val step4Active = deliveryState == "accepted" && journeyStep == 3
          TrackingStepItem(
            stepNumber = 4,
            title = "A Caminho",
            description = "O entregador de elite iniciou a rota de entrega expressa.",
            isActive = step4Active,
            isCompleted = step4Completed,
            showLine = true
          )

          // Step 5: Entregue
          val step5Completed = deliveryState == "idle" && activeOrder != null // Or simulated final step
          val step5Active = deliveryState == "accepted" && journeyStep >= 4
          TrackingStepItem(
            stepNumber = 5,
            title = "Pedido Entregue",
            description = "Bom apetite! Experiência gastronômica concluída.",
            isActive = step5Active,
            isCompleted = step5Completed,
            showLine = false
          )
        }
      }
      Spacer(modifier = Modifier.height(16.dp))
    }

    // RESUMO DA TRANSPARÊNCIA DE TAXAS (RODAPÉ EXPANSÍVEL)
    item {
      Card(
        modifier = Modifier
          .fillMaxWidth()
          .padding(vertical = 8.dp)
          .clickable { isExpandedFees = !isExpandedFees },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
      ) {
        Column(modifier = Modifier.padding(16.dp)) {
          Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
          ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Text("🧾", modifier = Modifier.padding(end = 8.dp))
              Text(
                text = "Resumo & Transparência de Taxas",
                style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
              )
            }
            Icon(
              imageVector = if (isExpandedFees) Icons.Default.KeyboardArrowDown else Icons.Default.KeyboardArrowDown, // Rotation or standard arrow
              contentDescription = "Expandir taxas",
              tint = MaterialTheme.colorScheme.primary
            )
          }

          AnimatedVisibility(visible = isExpandedFees) {
            Column(modifier = Modifier.padding(top = 16.dp)) {
              Divider(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.08f), modifier = Modifier.padding(bottom = 12.dp))

              Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("Subtotal dos pratos", style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)))
                Text("R$ ${activeOrder?.total?.replace("R$", "")?.trim() ?: "115.00"}", style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.SemiBold))
              }

              val taxaRastreio = if (selectedCityType == TipoCidade.CAPITAL) 3.00 else 2.00
              Row(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("Taxa de Entrega Limpa (100% Repassada)", style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.primary))
                Text("R$ ${String.format("%.2f", taxaRastreio)}", style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold))
              }

              Divider(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.08f), modifier = Modifier.padding(vertical = 12.dp))

              Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text("Total Pago", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                val totalOriginalStr = activeOrder?.total?.replace("R$", "")?.replace(",", ".")?.trim() ?: "115.00"
                val totalOriginalVal = totalOriginalStr.toDoubleOrNull() ?: 115.0
                // O total já inclui a taxa de entrega no checkout
                Text("R$ ${String.format("%.2f", totalOriginalVal)}", style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold))
              }

              Spacer(modifier = Modifier.height(12.dp))
              Box(
                modifier = Modifier
                  .fillMaxWidth()
                  .clip(RoundedCornerShape(8.dp))
                  .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.05f))
                  .padding(10.dp)
              ) {
                Text(
                  text = "Uni eats apoia o frete justo: esta taxa de R$ ${String.format("%.2f", taxaRastreio)} foi inteiramente destinada ao entregador parceiro Maurício Neves, sem qualquer retenção ou comissionamento por nossa plataforma.",
                  style = MaterialTheme.typography.labelSmall.copy(
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f),
                    lineHeight = 15.sp
                  )
                )
              }
            }
          }
        }
      }
    }
  }

  // DIÁLOGO DE CHAT SIMULADO COM O ENTREGADOR
  if (showChatDialog) {
    androidx.compose.ui.window.Dialog(onDismissRequest = { showChatDialog = false }) {
      Card(
        modifier = Modifier
          .fillMaxWidth()
          .height(450.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.2f))
      ) {
        Column(modifier = Modifier.fillMaxSize()) {
          // Chat Header
          Row(
            modifier = Modifier
              .fillMaxWidth()
              .background(MaterialTheme.colorScheme.surfaceVariant)
              .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
          ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
              Box(
                modifier = Modifier
                  .size(36.dp)
                  .clip(CircleShape)
                  .background(MaterialTheme.colorScheme.primary),
                contentAlignment = Alignment.Center
              ) {
                Text("🏍️", fontSize = 16.sp)
              }
              Spacer(modifier = Modifier.width(10.dp))
              Column {
                Text("Maurício Neves", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                Text("Online agora", style = MaterialTheme.typography.labelSmall.copy(color = Color(0xFF4CAF50), fontWeight = FontWeight.Bold))
              }
            }
            IconButton(onClick = { showChatDialog = false }) {
              Icon(imageVector = Icons.Default.Close, contentDescription = "Fechar chat")
            }
          }

          // Chat Body (Messages List)
          Box(
            modifier = Modifier
              .weight(1f)
              .fillMaxWidth()
              .background(Color(0xFF121212))
              .padding(12.dp)
          ) {
            androidx.compose.foundation.lazy.LazyColumn(
              modifier = Modifier.fillMaxSize(),
              verticalArrangement = Arrangement.Bottom
            ) {
              items(chatHistory) { (sender, text) ->
                val isMe = sender == "Me"
                Row(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                  horizontalArrangement = if (isMe) Arrangement.End else Arrangement.Start
                ) {
                  Box(
                    modifier = Modifier
                      .clip(
                        RoundedCornerShape(
                          topStart = 12.dp,
                          topEnd = 12.dp,
                          bottomStart = if (isMe) 12.dp else 0.dp,
                          bottomEnd = if (isMe) 0.dp else 12.dp
                        )
                      )
                      .background(if (isMe) MaterialTheme.colorScheme.primary else Color(0xFF2C2C2C))
                      .padding(12.dp)
                      .widthIn(max = 240.dp)
                  ) {
                    Text(
                      text = text,
                      style = MaterialTheme.typography.bodySmall.copy(
                        color = if (isMe) Color.Black else Color.White
                      )
                    )
                  }
                }
              }
            }
          }

          // Chat Footer (Input)
          Row(
            modifier = Modifier
              .fillMaxWidth()
              .background(MaterialTheme.colorScheme.surface)
              .padding(8.dp),
            verticalAlignment = Alignment.CenterVertically
          ) {
            OutlinedTextField(
              value = chatMessageText,
              onValueChange = { chatMessageText = it },
              placeholder = { Text("Escreva uma mensagem...", fontSize = 12.sp) },
              modifier = Modifier.weight(1f),
              shape = RoundedCornerShape(20.dp),
              colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                focusedContainerColor = Color(0xFF141414),
                unfocusedContainerColor = Color(0xFF141414)
              ),
              textStyle = MaterialTheme.typography.bodySmall
            )
            Spacer(modifier = Modifier.width(6.dp))
            IconButton(
              onClick = {
                if (chatMessageText.isNotBlank()) {
                  chatHistory.add("Me" to chatMessageText)
                  chatMessageText = ""
                }
              },
              modifier = Modifier
                .size(40.dp)
                .clip(CircleShape)
                .background(MaterialTheme.colorScheme.primary)
            ) {
              Text("➔", color = Color.Black, fontSize = 16.sp, fontWeight = FontWeight.Bold)
            }
          }
        }
      }
    }
  }
}

@Composable
fun TrackingStepItem(
  stepNumber: Int,
  title: String,
  description: String,
  isActive: Boolean,
  isCompleted: Boolean,
  showLine: Boolean
) {
  Row(
    modifier = Modifier.fillMaxWidth(),
    verticalAlignment = Alignment.Top
  ) {
    // Indicador Esquerdo (Círculo e Linha de Conexão)
    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
      modifier = Modifier.padding(end = 16.dp)
    ) {
      Box(
        modifier = Modifier
          .size(24.dp)
          .clip(CircleShape)
          .background(
            if (isCompleted) Color(0xFF4CAF50)
            else if (isActive) MaterialTheme.colorScheme.primary
            else Color(0xFF2C2C2C)
          )
          .border(
            width = if (isActive) 1.5.dp else 0.dp,
            color = if (isActive) Color.White else Color.Transparent,
            shape = CircleShape
          ),
        contentAlignment = Alignment.Center
      ) {
        if (isCompleted) {
          Text("✓", color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
        } else {
          Text(
            text = stepNumber.toString(),
            color = if (isActive) Color.Black else Color.White.copy(alpha = 0.4f),
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold
          )
        }
      }

      if (showLine) {
        Box(
          modifier = Modifier
            .width(2.dp)
            .height(45.dp)
            .background(
              if (isCompleted) Color(0xFF4CAF50)
              else if (isActive) MaterialTheme.colorScheme.primary.copy(alpha = 0.3f)
              else Color(0xFF2C2C2C)
            )
        )
      }
    }

    // Conteúdo do Texto do Step
    Column(modifier = Modifier.padding(bottom = 16.dp)) {
      Text(
        text = title,
        style = MaterialTheme.typography.bodyMedium.copy(
          fontWeight = FontWeight.Bold,
          color = if (isCompleted) Color(0xFF4CAF50)
                 else if (isActive) MaterialTheme.colorScheme.primary
                 else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
        )
      )
      Spacer(modifier = Modifier.height(2.dp))
      Text(
        text = description,
        style = MaterialTheme.typography.bodySmall.copy(
          color = if (isActive) MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f)
                 else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
        )
      )
    }
  }
}

@Composable
fun ExplorarScreenContent(
  restaurantList: List<Restaurant>,
  onRestaurantClick: (Restaurant) -> Unit
) {
  var query by remember { mutableStateOf("") }
  
  LazyColumn(
    modifier = Modifier
      .fillMaxSize()
      .padding(horizontal = 20.dp),
    contentPadding = PaddingValues(bottom = 90.dp)
  ) {
    item {
      Spacer(modifier = Modifier.height(24.dp))
      Text(
        text = "Curadoria de Experiências",
        style = MaterialTheme.typography.displayMedium.copy(
          color = MaterialTheme.colorScheme.primary,
          fontWeight = FontWeight.Light,
          fontSize = 28.sp,
          letterSpacing = 1.sp
        )
      )
      Text(
        text = "EVENTOS PRIVILEGIADOS E CHEFS EXCLUSIVOS",
        style = MaterialTheme.typography.labelSmall.copy(
          color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f),
          fontWeight = FontWeight.Bold,
          letterSpacing = 2.sp
        ),
        modifier = Modifier.padding(top = 4.dp, bottom = 24.dp)
      )
    }

    item {
      SearchBar(query = query, onQueryChange = { query = it })
      Spacer(modifier = Modifier.height(24.dp))
    }

    // Curated Experiences
    item {
      Text(
        text = "Altas Experiências Gastronômicas",
        style = MaterialTheme.typography.titleLarge.copy(
          color = MaterialTheme.colorScheme.onBackground,
          fontWeight = FontWeight.SemiBold
        ),
        modifier = Modifier.padding(bottom = 12.dp)
      )
    }

    val experiences = listOf(
      Triple("Jantar Secreto de Outono", "R$ 490/p", "Menu degustação de 8 tempos revelado apenas 24h antes do evento."),
      Triple("Masterclass de Trufas Frescas", "R$ 680/p", "Aprenda a harmonizar trufas negras com vinhos Brunello di Montalcino."),
      Triple("Private Chef at Home", "Sob Consulta", "Leve um Chef com Estrela Michelin para cozinhar na sua residência.")
    )

    items(experiences) { (title, price, desc) ->
      Card(
        modifier = Modifier
          .fillMaxWidth()
          .padding(vertical = 8.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)),
        shape = RoundedCornerShape(16.dp)
      ) {
        Column(modifier = Modifier.padding(18.dp)) {
          Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
          ) {
            Text(
              text = title,
              style = MaterialTheme.typography.titleMedium.copy(
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurface
              )
            )
            Box(
              modifier = Modifier
                .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f), RoundedCornerShape(6.dp))
                .padding(horizontal = 8.dp, vertical = 4.dp)
            ) {
              Text(
                text = price,
                style = MaterialTheme.typography.labelSmall.copy(
                  color = MaterialTheme.colorScheme.primary,
                  fontWeight = FontWeight.Bold
                )
              )
            }
          }
          Spacer(modifier = Modifier.height(8.dp))
          Text(
            text = desc,
            style = MaterialTheme.typography.bodyMedium.copy(
              color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
            )
          )
          Spacer(modifier = Modifier.height(16.dp))
          Button(
            onClick = { /* Simulate reserve dialog */ },
            modifier = Modifier.align(Alignment.End),
            colors = ButtonDefaults.buttonColors(
              containerColor = MaterialTheme.colorScheme.primary,
              contentColor = MaterialTheme.colorScheme.onPrimary
            ),
            shape = RoundedCornerShape(18.dp)
          ) {
            Text(
              text = "RESERVAR VAGA",
              style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold)
            )
          }
        }
      }
    }
  }
}

@Composable
fun SacolaScreenContent(
  itemsCount: Int,
  selectedCityType: TipoCidade,
  onCityTypeChange: (TipoCidade) -> Unit,
  onClearCart: () -> Unit,
  onOrderCreated: (Order) -> Unit,
  onNavigateToChef: () -> Unit
) {
  val paymentService = remember { MercadoPagoService() }
  val clipboardManager = LocalClipboardManager.current

  // Step state: "cart", "payment", "processing", "pix_success", "success_complete", "payment_failed"
  var checkoutStep by remember { mutableStateOf("cart") }
  var selectedPaymentMethod by remember { mutableStateOf("pix") } // "pix" or "card"
  
  // Pix generation response
  var pixResponse by remember { mutableStateOf<MercadoPagoService.PaymentResponse?>(null) }
  var isPixKeyCopied by remember { mutableStateOf(false) }

  // Credit Card Form States
  var cardNumber by remember { mutableStateOf("") }
  var cardHolderName by remember { mutableStateOf("") }
  var cardExpiry by remember { mutableStateOf("") }
  var cardCvv by remember { mutableStateOf("") }
  var cardInstallments by remember { mutableStateOf(1) }
  var cardPaymentResponse by remember { mutableStateOf<MercadoPagoService.PaymentResponse?>(null) }
  
  var formErrorMessage by remember { mutableStateOf<String?>(null) }

  // Pricing values & simulation toggles
  var isEconomicSimulation by remember { mutableStateOf(false) }
  var deliveryMethod by remember { mutableStateOf("motoboy") } // "motoboy" or "retirada"

  val pricePerItem = if (isEconomicSimulation) 10.00 else 380.00
  val subtotal = pricePerItem * itemsCount
  val deliveryFee = if (deliveryMethod == "motoboy") {
    CalculadoraLogisticaService.calcularParcelaCliente(selectedCityType)
  } else {
    0.0
  }
  val isSafetyLockActive = deliveryMethod == "motoboy" && subtotal < 15.00 && itemsCount > 0
  val discount = if (itemsCount > 0 && !isEconomicSimulation) 30.00 else 0.00
  val total = if (itemsCount > 0) (subtotal + deliveryFee - discount).coerceAtLeast(0.0) else 0.0

  Column(
    modifier = Modifier
      .fillMaxSize()
      .padding(horizontal = 20.dp),
    horizontalAlignment = Alignment.CenterHorizontally,
    verticalArrangement = if (itemsCount == 0 && checkoutStep == "cart") Arrangement.Center else Arrangement.Top
  ) {
    if (itemsCount == 0 && checkoutStep == "cart") {
      Icon(
        imageVector = Icons.Default.LocalMall,
        contentDescription = "Sacola vazia",
        tint = MaterialTheme.colorScheme.primary.copy(alpha = 0.3f),
        modifier = Modifier.size(64.dp)
      )
      Spacer(modifier = Modifier.height(16.dp))
      Text(
        text = "Sua sacola está vazia",
        style = MaterialTheme.typography.titleLarge.copy(
          color = MaterialTheme.colorScheme.onBackground,
          fontWeight = FontWeight.SemiBold
        )
      )
      Spacer(modifier = Modifier.height(4.dp))
      Text(
        text = "Navegue pelo menu dos nossos parceiros premium e adicione pratos exclusivos.",
        style = MaterialTheme.typography.bodyMedium.copy(
          color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
        ),
        textAlign = TextAlign.Center
      )
    } else {
      // HEADER DYNAMIC BY WIZARD STEP
      Spacer(modifier = Modifier.height(24.dp))
      
      Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
      ) {
        Row(
          verticalAlignment = Alignment.CenterVertically,
          modifier = Modifier.weight(1f)
        ) {
          if (checkoutStep != "cart" && checkoutStep != "success_complete" && checkoutStep != "processing") {
            Icon(
              imageVector = Icons.Default.ArrowBack,
              contentDescription = "Voltar",
              tint = MaterialTheme.colorScheme.primary,
              modifier = Modifier
                .padding(end = 12.dp)
                .size(24.dp)
                .clickable {
                  if (checkoutStep == "pix_success" || checkoutStep == "payment_failed") {
                    checkoutStep = "payment"
                  } else if (checkoutStep == "payment") {
                    checkoutStep = "cart"
                  }
                }
            )
          }
          Column {
            Text(
              text = when (checkoutStep) {
                "cart" -> "Sua Sacola"
                "payment" -> "Pagamento"
                "processing" -> "Processando"
                "pix_success" -> "Código Pix"
                "payment_failed" -> "Falha no Pagamento"
                else -> "Pedido Confirmado"
              },
              style = MaterialTheme.typography.displayMedium.copy(
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Light,
                fontSize = 28.sp,
                letterSpacing = 1.sp
              )
            )
            Text(
              text = when (checkoutStep) {
                "cart" -> "REVISÃO DOS ITENS SELECIONADOS"
                "payment" -> "GATEWAY DE PAGAMENTO SEGURO"
                "processing" -> "COMUNICANDO COM MERCADO PAGO"
                "pix_success" -> "AGUARDANDO TRANSFERÊNCIA PIX"
                "payment_failed" -> "TRANSAÇÃO RECUSADA PELA API"
                else -> "SUA RESERVA FOI ENVIADA AO CHEF"
              },
              style = MaterialTheme.typography.labelSmall.copy(
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f),
                fontWeight = FontWeight.Bold,
                letterSpacing = 1.5.sp
              ),
              modifier = Modifier.padding(top = 4.dp)
            )
          }
        }

        if (checkoutStep == "cart") {
          Text(
            text = "Limpar",
            style = MaterialTheme.typography.labelLarge.copy(
              color = MaterialTheme.colorScheme.primary,
              fontWeight = FontWeight.Bold
            ),
            modifier = Modifier.clickable { onClearCart() }
          )
        }
      }

      Spacer(modifier = Modifier.height(24.dp))

      Crossfade(targetState = checkoutStep, label = "CheckoutStepAnimation") { currentStep ->
        when (currentStep) {
          "cart" -> {
            Column {
              // ====================================================================
              // 1. SIMULATION AND LOGISTICS SELECTORS (Rule 1 & 2)
              // ====================================================================
              Card(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(bottom = 16.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.12f)),
                shape = RoundedCornerShape(16.dp)
              ) {
                Column(modifier = Modifier.padding(16.dp)) {
                  Text(
                    text = "Configurações de Simulação & Logística",
                    style = MaterialTheme.typography.titleSmall.copy(
                      color = MaterialTheme.colorScheme.primary,
                      fontWeight = FontWeight.Bold
                    )
                  )
                  Spacer(modifier = Modifier.height(12.dp))

                  // Toggle for City Type
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Column(modifier = Modifier.weight(1f)) {
                      Text(text = "Cidade do Restaurante", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                      Text(
                        text = if (selectedCityType == TipoCidade.CAPITAL) "Capital/Grande Cidade (Split R$ 6)" else "Interior/Pequena Cidade (Split R$ 4)",
                        style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                      )
                    }
                    Row {
                      Button(
                        onClick = { onCityTypeChange(TipoCidade.INTERIOR) },
                        colors = ButtonDefaults.buttonColors(
                          containerColor = if (selectedCityType == TipoCidade.INTERIOR) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant
                        ),
                        modifier = Modifier.height(32.dp).padding(end = 4.dp),
                        contentPadding = PaddingValues(horizontal = 8.dp),
                        shape = RoundedCornerShape(8.dp)
                      ) {
                        Text("Interior", fontSize = 10.sp, color = if (selectedCityType == TipoCidade.INTERIOR) Color.Black else MaterialTheme.colorScheme.onSurfaceVariant)
                      }
                      Button(
                        onClick = { onCityTypeChange(TipoCidade.CAPITAL) },
                        colors = ButtonDefaults.buttonColors(
                          containerColor = if (selectedCityType == TipoCidade.CAPITAL) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant
                        ),
                        modifier = Modifier.height(32.dp),
                        contentPadding = PaddingValues(horizontal = 8.dp),
                        shape = RoundedCornerShape(8.dp)
                      ) {
                        Text("Capital", fontSize = 10.sp, color = if (selectedCityType == TipoCidade.CAPITAL) Color.Black else MaterialTheme.colorScheme.onSurfaceVariant)
                      }
                    }
                  }

                  Spacer(modifier = Modifier.height(12.dp))
                  Box(modifier = Modifier.fillMaxWidth().height(0.5.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.1f)))
                  Spacer(modifier = Modifier.height(12.dp))

                  // Toggle for Delivery Method
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Column(modifier = Modifier.weight(1f)) {
                      Text(text = "Método de Entrega", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                      Text(
                        text = if (deliveryMethod == "motoboy") "Entrega por Motoboy (Rede Uni eats)" else "Retirada no estabelecimento",
                        style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                      )
                    }
                    Row {
                      Button(
                        onClick = { deliveryMethod = "motoboy" },
                        colors = ButtonDefaults.buttonColors(
                          containerColor = if (deliveryMethod == "motoboy") MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant
                        ),
                        modifier = Modifier.height(32.dp).padding(end = 4.dp),
                        contentPadding = PaddingValues(horizontal = 8.dp),
                        shape = RoundedCornerShape(8.dp)
                      ) {
                        Text("Entrega", fontSize = 10.sp, color = if (deliveryMethod == "motoboy") Color.Black else MaterialTheme.colorScheme.onSurfaceVariant)
                      }
                      Button(
                        onClick = { deliveryMethod = "retirada" },
                        colors = ButtonDefaults.buttonColors(
                          containerColor = if (deliveryMethod == "retirada") MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.surfaceVariant
                        ),
                        modifier = Modifier.height(32.dp),
                        contentPadding = PaddingValues(horizontal = 8.dp),
                        shape = RoundedCornerShape(8.dp)
                      ) {
                        Text("Retirada", fontSize = 10.sp, color = if (deliveryMethod == "retirada") Color.Black else MaterialTheme.colorScheme.onSurfaceVariant)
                      }
                    }
                  }

                  Spacer(modifier = Modifier.height(12.dp))
                  Box(modifier = Modifier.fillMaxWidth().height(0.5.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.1f)))
                  Spacer(modifier = Modifier.height(12.dp))

                  // Toggle for Value Simulation (Wagyu vs Cheap)
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Column(modifier = Modifier.weight(1.5f)) {
                      Text(text = "Simulador de Valor de Pedido", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                      Text(
                        text = "Altere o valor do carrinho para testar a trava de mínimo de R$ 15,00.",
                        style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                      )
                    }
                    Button(
                      onClick = { isEconomicSimulation = !isEconomicSimulation },
                      colors = ButtonDefaults.buttonColors(
                        containerColor = if (isEconomicSimulation) Color(0xFFEF5350) else Color(0xFF2E7D32)
                      ),
                      modifier = Modifier.height(36.dp).weight(1f),
                      contentPadding = PaddingValues(horizontal = 4.dp),
                      shape = RoundedCornerShape(10.dp)
                    ) {
                      Text(
                        text = if (isEconomicSimulation) "Econômico R$ 10" else "Signature R$ 380",
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                      )
                    }
                  }
                }
              }

              // ====================================================================
              // 2. CHECKOUT SUMMARY CARD
              // ====================================================================
              Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)),
                shape = RoundedCornerShape(16.dp)
              ) {
                Column(modifier = Modifier.padding(20.dp)) {
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Text(
                      text = "Resumo dos Itens",
                      style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                    )
                    Text(
                      text = "$itemsCount prato(s)",
                      style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.primary)
                    )
                  }

                  Spacer(modifier = Modifier.height(16.dp))

                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                  ) {
                    Text(
                      text = if (isEconomicSimulation) "Porção Econômica de Teste" else "Signature Menu Selection",
                      style = MaterialTheme.typography.bodyLarge
                    )
                    Text(
                      text = "R$ ${String.format("%.2f", subtotal)}",
                      style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.Bold)
                    )
                  }

                  Spacer(modifier = Modifier.height(16.dp))
                  Box(modifier = Modifier.fillMaxWidth().height(0.5.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.3f)))
                  Spacer(modifier = Modifier.height(16.dp))

                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                  ) {
                    Text(
                      text = "Taxa de Entrega (${if (deliveryMethod == "motoboy") "Rede Uni eats" else "Retirada"})",
                      style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f))
                    )
                    Text(
                      text = if (deliveryMethod == "motoboy") {
                        "R$ ${String.format("%.2f", deliveryFee)} (${if (selectedCityType == TipoCidade.CAPITAL) "Capital" else "Interior"})"
                      } else {
                        "Isento"
                      },
                      style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                    )
                  }
                  
                  if (deliveryMethod == "motoboy") {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                      text = "Nota: R$ ${String.format("%.2f", deliveryFee)} pagos pelo cliente, R$ ${String.format("%.2f", deliveryFee)} pagos pelo restaurante.",
                      style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f), fontSize = 9.sp)
                    )
                  }

                  if (discount > 0.0) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Row(
                      modifier = Modifier.fillMaxWidth(),
                      horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                      Text(
                        text = "Desconto Cupom Select",
                        style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f))
                      )
                      Text(
                        text = "- R$ ${String.format("%.2f", discount)}",
                        style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                      )
                    }
                  }

                  Spacer(modifier = Modifier.height(20.dp))
                  Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(MaterialTheme.colorScheme.primary.copy(alpha = 0.3f)))
                  Spacer(modifier = Modifier.height(20.dp))

                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Text(text = "Total Estimado", style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold))
                    Text(
                      text = "R$ ${String.format("%.2f", total)}",
                      style = MaterialTheme.typography.titleLarge.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                    )
                  }
                }
              }

              Spacer(modifier = Modifier.height(24.dp))

              // ====================================================================
              // 3. SAFETY LOCK WARNING AND PROCEED BUTTON (Rule 2)
              // ====================================================================
              if (isSafetyLockActive) {
                // TRAVA DE SEGURANÇA CONTRA PREJUÍZO ATIVA!
                Card(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 16.dp),
                  colors = CardDefaults.cardColors(containerColor = Color(0xFFEF5350).copy(alpha = 0.08f)),
                  border = BorderStroke(1.dp, Color(0xFFEF5350).copy(alpha = 0.3f)),
                  shape = RoundedCornerShape(12.dp)
                ) {
                  Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Text(text = "⚠️", fontSize = 24.sp, modifier = Modifier.padding(end = 12.dp))
                    Column {
                      Text(
                        text = "ALERTA DE SEGURANÇA CONTRA PREJUÍZO",
                        style = MaterialTheme.typography.labelSmall.copy(color = Color(0xFFEF5350), fontWeight = FontWeight.Bold, letterSpacing = 0.5.sp)
                      )
                      Spacer(modifier = Modifier.height(4.dp))
                      Text(
                        text = "A taxa de logística mínima exige que o pedido tenha um valor mínimo de produtos de R$ 15,00 para entrega via Motoboy.",
                        style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f))
                      )
                      Spacer(modifier = Modifier.height(6.dp))
                      Text(
                        text = "Ação Sugerida: Altere o método de entrega para 'Retirada' ou adicione itens premium à sua sacola.",
                        style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                      )
                    }
                  }
                }

                // Disabled checkout button showing lock status
                Button(
                  onClick = { },
                  enabled = false,
                  modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                  colors = ButtonDefaults.buttonColors(
                    disabledContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                    disabledContentColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.3f)
                  ),
                  shape = RoundedCornerShape(28.dp)
                ) {
                  Text(
                    text = "ENTREGA BLOQUEADA (MÍNIMO R$ 15,00)",
                    style = MaterialTheme.typography.labelLarge.copy(
                      fontWeight = FontWeight.Bold,
                      letterSpacing = 1.sp
                    )
                  )
                }
              } else {
                // Flow works normally!
                Button(
                  onClick = { checkoutStep = "payment" },
                  modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp),
                  colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    contentColor = Color.Black
                  ),
                  shape = RoundedCornerShape(28.dp)
                ) {
                  Text(
                    text = "PROSSEGUIR PARA O PAGAMENTO",
                    style = MaterialTheme.typography.labelLarge.copy(
                      fontWeight = FontWeight.Bold,
                      letterSpacing = 1.sp
                    )
                  )
                }
              }
            }
          }

          "payment" -> {
            LazyColumn(
              modifier = Modifier.fillMaxSize(),
              contentPadding = PaddingValues(bottom = 60.dp)
            ) {
              // Elegant values summary
              item {
                Card(
                  modifier = Modifier.fillMaxWidth(),
                  colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.15f)),
                  border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.12f)),
                  shape = RoundedCornerShape(16.dp)
                ) {
                  Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                      text = "Resumo do Pedido",
                      style = MaterialTheme.typography.labelMedium.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                    )
                    Spacer(modifier = Modifier.height(10.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                      Text(text = "Signature Selection ($itemsCount pratos)", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f))
                      Text(text = "R$ ${String.format("%.2f", subtotal)}", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                    }
                    Spacer(modifier = Modifier.height(6.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                      Text(text = "Desconto Membro Select", style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f))
                      Text(text = "- R$ ${String.format("%.2f", discount)}", style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold))
                    }
                    Spacer(modifier = Modifier.height(12.dp))
                    Box(modifier = Modifier.fillMaxWidth().height(0.5.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)))
                    Spacer(modifier = Modifier.height(12.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                      Text(text = "Total Líquido", style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold))
                      Text(text = "R$ ${String.format("%.2f", total)}", style = MaterialTheme.typography.titleMedium.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Black))
                    }
                  }
                }
                Spacer(modifier = Modifier.height(24.dp))
              }

              // Payment selector
              item {
                Text(
                  text = "Selecione o Método de Pagamento:",
                  style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f), fontWeight = FontWeight.Bold),
                  modifier = Modifier.padding(bottom = 12.dp)
                )

                Row(
                  modifier = Modifier.fillMaxWidth(),
                  horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                  // Pix Option card
                  val isPixSelected = selectedPaymentMethod == "pix"
                  Card(
                    modifier = Modifier
                      .weight(1f)
                      .clickable { selectedPaymentMethod = "pix" },
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(
                      width = if (isPixSelected) 2.dp else 1.dp,
                      color = if (isPixSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)
                    ),
                    colors = CardDefaults.cardColors(
                      containerColor = if (isPixSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.05f) else MaterialTheme.colorScheme.surface
                    )
                  ) {
                    Column(
                      modifier = Modifier.padding(16.dp),
                      horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                      Icon(
                        imageVector = Icons.Default.QrCode,
                        contentDescription = "Pix",
                        tint = if (isPixSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                        modifier = Modifier.size(28.dp)
                      )
                      Spacer(modifier = Modifier.height(8.dp))
                      Text(
                        text = "Pix",
                        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                      )
                      Text(
                        text = "Instantâneo",
                        style = MaterialTheme.typography.labelSmall.copy(
                          color = MaterialTheme.colorScheme.primary,
                          fontSize = 8.sp,
                          letterSpacing = 0.5.sp
                        )
                      )
                    }
                  }

                  // Card Option card
                  val isCardSelected = selectedPaymentMethod == "card"
                  Card(
                    modifier = Modifier
                      .weight(1f)
                      .clickable { selectedPaymentMethod = "card" },
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(
                      width = if (isCardSelected) 2.dp else 1.dp,
                      color = if (isCardSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)
                    ),
                    colors = CardDefaults.cardColors(
                      containerColor = if (isCardSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.05f) else MaterialTheme.colorScheme.surface
                    )
                  ) {
                    Column(
                      modifier = Modifier.padding(16.dp),
                      horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                      Icon(
                        imageVector = Icons.Default.CreditCard,
                        contentDescription = "Cartão de Crédito",
                        tint = if (isCardSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                        modifier = Modifier.size(28.dp)
                      )
                      Spacer(modifier = Modifier.height(8.dp))
                      Text(
                        text = "Cartão",
                        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                      )
                      Text(
                        text = "Crédito/Débito",
                        style = MaterialTheme.typography.labelSmall.copy(
                          color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                          fontSize = 8.sp
                        )
                      )
                    }
                  }
                }
                Spacer(modifier = Modifier.height(24.dp))
              }

              // Dynamic Payment Input Fields
              if (selectedPaymentMethod == "pix") {
                item {
                  Box(
                    modifier = Modifier
                      .fillMaxWidth()
                      .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))
                      .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.1f), RoundedCornerShape(16.dp))
                      .padding(16.dp)
                  ) {
                    Column {
                      Text(
                        text = "Pague com Pix Seguro",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                      )
                      Spacer(modifier = Modifier.height(4.dp))
                      Text(
                        text = "A provisão de QR Code e chave EMV é gerenciada pela API Mercado Pago com criptografia SSL.",
                        style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                      )
                      
                      Spacer(modifier = Modifier.height(16.dp))

                      var payerEmail by remember { mutableStateOf("aquilaa043@gmail.com") }
                      OutlinedTextField(
                        value = payerEmail,
                        onValueChange = { payerEmail = it },
                        label = { Text("E-mail para Recibo de Transação") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(
                          focusedBorderColor = MaterialTheme.colorScheme.primary,
                          unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f),
                          focusedContainerColor = MaterialTheme.colorScheme.background,
                          unfocusedContainerColor = MaterialTheme.colorScheme.background
                        ),
                        shape = RoundedCornerShape(12.dp),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email)
                      )

                      Spacer(modifier = Modifier.height(24.dp))

                      Button(
                        onClick = {
                          checkoutStep = "processing"
                        },
                        modifier = Modifier
                          .fillMaxWidth()
                          .height(52.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary),
                        shape = RoundedCornerShape(26.dp)
                      ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                          Icon(imageVector = Icons.Default.Lock, contentDescription = "Security lock", modifier = Modifier.size(16.dp))
                          Spacer(modifier = Modifier.width(8.dp))
                          Text(
                            text = "GERAR PIX SEGURO (R$ ${String.format("%.2f", total)})",
                            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold)
                          )
                        }
                      }
                    }
                  }
                }
              } else {
                // CREDIT CARD FORM WITH FORMATTING AND SIMULATOR TOOLTIPS
                item {
                  Box(
                    modifier = Modifier
                      .fillMaxWidth()
                      .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(16.dp))
                      .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.1f), RoundedCornerShape(16.dp))
                      .padding(16.dp)
                  ) {
                    Column {
                      Text(
                        text = "Dados do Cartão de Crédito",
                        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                      )
                      Spacer(modifier = Modifier.height(4.dp))
                      Text(
                        text = "Tokenização local direta para a API do Mercado Pago.",
                        style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                      )

                      Spacer(modifier = Modifier.height(16.dp))

                      // Card Number Input with auto spacing formatting
                      OutlinedTextField(
                        value = cardNumber,
                        onValueChange = { input ->
                          val clean = input.filter { it.isDigit() }.take(16)
                          var formatted = ""
                          for (i in clean.indices) {
                            formatted += clean[i]
                            if ((i + 1) % 4 == 0 && i != 15) {
                              formatted += " "
                            }
                          }
                          cardNumber = formatted
                          formErrorMessage = null
                        },
                        label = { Text("Número do Cartão") },
                        placeholder = { Text("0000 0000 0000 0000") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(
                          focusedBorderColor = MaterialTheme.colorScheme.primary,
                          unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f),
                          focusedContainerColor = MaterialTheme.colorScheme.background,
                          unfocusedContainerColor = MaterialTheme.colorScheme.background
                        ),
                        shape = RoundedCornerShape(12.dp),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number, imeAction = ImeAction.Next)
                      )

                      Spacer(modifier = Modifier.height(10.dp))

                      // Holder Name
                      OutlinedTextField(
                        value = cardHolderName,
                        onValueChange = { 
                          cardHolderName = it.uppercase()
                          formErrorMessage = null
                        },
                        label = { Text("Nome do Titular (Como no Cartão)") },
                        placeholder = { Text("GUILHERME S PRADO") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(
                          focusedBorderColor = MaterialTheme.colorScheme.primary,
                          unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f),
                          focusedContainerColor = MaterialTheme.colorScheme.background,
                          unfocusedContainerColor = MaterialTheme.colorScheme.background
                        ),
                        shape = RoundedCornerShape(12.dp),
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text, imeAction = ImeAction.Next)
                      )

                      Spacer(modifier = Modifier.height(10.dp))

                      Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        // Expiry MM/YY
                        OutlinedTextField(
                          value = cardExpiry,
                          onValueChange = { input ->
                            val clean = input.filter { it.isDigit() }.take(4)
                            var formatted = ""
                            for (i in clean.indices) {
                              formatted += clean[i]
                              if (i == 1 && clean.length > 2) {
                                formatted += "/"
                              }
                            }
                            cardExpiry = formatted
                            formErrorMessage = null
                          },
                          label = { Text("Vencimento") },
                          placeholder = { Text("MM/YY") },
                          modifier = Modifier.weight(1f),
                          colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = MaterialTheme.colorScheme.primary,
                            unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f),
                            focusedContainerColor = MaterialTheme.colorScheme.background,
                            unfocusedContainerColor = MaterialTheme.colorScheme.background
                          ),
                          shape = RoundedCornerShape(12.dp),
                          singleLine = true,
                          keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number, imeAction = ImeAction.Next)
                        )

                        // CVV
                        OutlinedTextField(
                          value = cardCvv,
                          onValueChange = { input ->
                            cardCvv = input.filter { it.isDigit() }.take(4)
                            formErrorMessage = null
                          },
                          label = { Text("CVC/CVV") },
                          placeholder = { Text("123") },
                          modifier = Modifier.weight(1f),
                          colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = MaterialTheme.colorScheme.primary,
                            unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f),
                            focusedContainerColor = MaterialTheme.colorScheme.background,
                            unfocusedContainerColor = MaterialTheme.colorScheme.background
                          ),
                          shape = RoundedCornerShape(12.dp),
                          singleLine = true,
                          keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number, imeAction = ImeAction.Done)
                        )
                      }

                      // Dynamic validation error if present
                      formErrorMessage?.let { err ->
                        Spacer(modifier = Modifier.height(10.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                          Icon(imageVector = Icons.Default.Warning, contentDescription = "Erro", tint = Color(0xFFEF5350), modifier = Modifier.size(16.dp))
                          Spacer(modifier = Modifier.width(6.dp))
                          Text(text = err, style = MaterialTheme.typography.bodySmall.copy(color = Color(0xFFEF5350), fontWeight = FontWeight.Bold))
                        }
                      }

                      Spacer(modifier = Modifier.height(14.dp))
                      Box(modifier = Modifier.fillMaxWidth().height(0.5.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)))
                      Spacer(modifier = Modifier.height(14.dp))

                      // SANDBOX CREDIT CARD SIMULATOR HELPER INFOBOX
                      Box(
                        modifier = Modifier
                          .fillMaxWidth()
                          .background(Color(0xFF2196F3).copy(alpha = 0.08f), RoundedCornerShape(10.dp))
                          .border(0.5.dp, Color(0xFF2196F3).copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                          .padding(10.dp)
                      ) {
                        Column {
                          Row {
                            Text(text = "💡 ", fontSize = 12.sp)
                            Text(
                              text = "Simulador de Sandbox Mercado Pago:",
                              style = MaterialTheme.typography.bodySmall.copy(color = Color(0xFF90CAF9), fontWeight = FontWeight.Bold)
                            )
                          }
                          Spacer(modifier = Modifier.height(2.dp))
                          Text(
                            text = "• CVV \"666\" -> Simula Recusa por Saldo Insuficiente\n• CVV \"777\" -> Simula Recusa por Antifraude (Alto Risco)\n• Outros CVVs -> Simula Aprovado instantaneamente",
                            style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f), fontSize = 11.sp),
                            modifier = Modifier.padding(start = 14.dp)
                          )
                        }
                      }

                      Spacer(modifier = Modifier.height(20.dp))

                      Button(
                        onClick = {
                          val cleanCardNum = cardNumber.replace(" ", "")
                          if (cleanCardNum.length < 16) {
                            formErrorMessage = "Insira um número de cartão de crédito válido (16 dígitos)."
                          } else if (cardHolderName.trim().length < 3) {
                            formErrorMessage = "Insira o nome impresso no cartão completo."
                          } else if (cardExpiry.length < 5) {
                            formErrorMessage = "Insira uma data de validade válida (MM/YY)."
                          } else if (cardCvv.length < 3) {
                            formErrorMessage = "CVV inválido (deve conter 3 ou 4 dígitos)."
                          } else {
                            formErrorMessage = null
                            checkoutStep = "processing"
                          }
                        },
                        modifier = Modifier
                          .fillMaxWidth()
                          .height(52.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary),
                        shape = RoundedCornerShape(26.dp)
                      ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                          Icon(imageVector = Icons.Default.Lock, contentDescription = "Security lock", modifier = Modifier.size(16.dp))
                          Spacer(modifier = Modifier.width(8.dp))
                          Text(
                            text = "PAGAR COM CARTÃO (R$ ${String.format("%.2f", total)})",
                            style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold)
                          )
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          "processing" -> {
            var simulatedProgressText by remember { mutableStateOf("Contatando servidores do Mercado Pago...") }
            
            LaunchedEffect(selectedPaymentMethod) {
              if (selectedPaymentMethod == "pix") {
                simulatedProgressText = "Gerando cobrança Pix via API..."
                pixResponse = paymentService.createPixPayment(total, "aquilaa043@gmail.com")
                checkoutStep = "pix_success"
              } else {
                simulatedProgressText = "Enviando card_token e analisando antifraude..."
                delay(1200)
                simulatedProgressText = "Verificando autorização com banco emissor..."
                val response = paymentService.createCardPayment(total, cardNumber, cardHolderName, cardExpiry, cardCvv)
                cardPaymentResponse = response
                if (response.status == MercadoPagoService.PaymentStatus.APPROVED) {
                  // Construct dynamic Order representation
                  val simulatedOrder = Order(
                    id = "#${(2085..9999).random()}",
                    customerName = cardHolderName.ifBlank { "Guilherme Prado" },
                    customerPhone = "+55 11 99888-7766",
                    customerAddress = "Alameda Lorena, 1200 - Jardins, SP",
                    orderTime = "Agora",
                    items = listOf(OrderItem("Signature Menu Selection", itemsCount, "R$ ${String.format("%.2f", pricePerItem)}")),
                    notes = "Aprovado via Cartão Mercado Pago ID ${response.paymentId}",
                    deliveryType = "Rede Uni eats",
                    status = OrderStatus.NOVOS,
                    total = "R$ ${String.format("%.2f", total)}"
                  )
                  onOrderCreated(simulatedOrder)
                  checkoutStep = "success_complete"
                } else {
                  checkoutStep = "payment_failed"
                }
              }
            }

            Box(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 64.dp),
              contentAlignment = Alignment.Center
            ) {
              Column(horizontalAlignment = Alignment.CenterHorizontally) {
                CircularProgressIndicator(
                  color = MaterialTheme.colorScheme.primary,
                  modifier = Modifier.size(56.dp),
                  strokeWidth = 4.dp
                )
                Spacer(modifier = Modifier.height(24.dp))
                Text(
                  text = simulatedProgressText,
                  style = MaterialTheme.typography.bodyLarge.copy(fontWeight = FontWeight.Medium),
                  color = MaterialTheme.colorScheme.onBackground
                )
                Text(
                  text = "Uni eats opera com canais criptografados de ponta-a-ponta.",
                  style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)),
                  modifier = Modifier.padding(top = 8.dp)
                )
              }
            }
          }

          "pix_success" -> {
            pixResponse?.let { pix ->
              Column {
                Card(
                  modifier = Modifier.fillMaxWidth(),
                  colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                  border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)),
                  shape = RoundedCornerShape(16.dp)
                ) {
                  Column(
                    modifier = Modifier.padding(20.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                  ) {
                    Text(
                      text = "Código Copiado ou QR Code",
                      style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                      textAlign = TextAlign.Center
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                      text = "Transfira o valor total exato de R$ ${String.format("%.2f", total)} para aprovação imediata.",
                      style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)),
                      textAlign = TextAlign.Center
                    )

                    Spacer(modifier = Modifier.height(20.dp))

                    // HIGH FIDELITY PROCEDURALLY DRAWN CUSTOM QR CODE
                    Box(
                      modifier = Modifier
                        .size(160.dp)
                        .background(Color.White, RoundedCornerShape(12.dp))
                        .padding(12.dp),
                      contentAlignment = Alignment.Center
                    ) {
                      // Canvas drawing high contrast QR Code simulated pattern
                      Canvas(modifier = Modifier.fillMaxSize()) {
                        val cellSize = size.width / 11f
                        
                        // Function to draw black pixels
                        fun drawBlock(row: Int, col: Int) {
                          drawRect(
                            color = Color(0xFF1E1E1E),
                            topLeft = androidx.compose.ui.geometry.Offset(col * cellSize, row * cellSize),
                            size = androidx.compose.ui.geometry.Size(cellSize, cellSize)
                          )
                        }

                        // Finding anchors (Standard corners)
                        for (r in 0..10) {
                          for (c in 0..10) {
                            // Top-Left corner finder
                            if ((r in 0..2 && c in 0..2) || (r == 0 && c == 3) || (r == 3 && c in 0..3)) {
                              if (!(r == 1 && c == 1)) {
                                drawBlock(r, c)
                              }
                            }
                            // Top-Right corner finder
                            if ((r in 0..2 && c in 8..10) || (r == 0 && c == 7) || (r == 3 && c in 7..10)) {
                              if (!(r == 1 && c == 9)) {
                                drawBlock(r, c)
                              }
                            }
                            // Bottom-Left corner finder
                            if ((r in 8..10 && c in 0..2) || (r == 7 && c == 0) || (r == 7 && c in 0..3)) {
                              if (!(r == 9 && c == 1)) {
                                drawBlock(r, c)
                              }
                            }
                            
                            // Random-like fill for center bits to simulate QR Code data payload
                            if (r in 4..7 && c in 4..7) {
                              if ((r + c) % 2 == 0) drawBlock(r, c)
                            }
                            if (r in 2..5 && c in 4..5) {
                              if ((r * c) % 3 == 0) drawBlock(r, c)
                            }
                            if (r in 6..9 && c in 7..9) {
                              if ((r - c) % 2 != 0) drawBlock(r, c)
                            }
                          }
                        }
                      }
                    }

                    Spacer(modifier = Modifier.height(20.dp))

                    Text(
                      text = "Código Copia e Cola Pix:",
                      style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f), fontWeight = FontWeight.Bold),
                      modifier = Modifier.align(Alignment.Start)
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    // Pix copy container clickable
                    Box(
                      modifier = Modifier
                        .fillMaxWidth()
                        .background(MaterialTheme.colorScheme.background, RoundedCornerShape(10.dp))
                        .border(0.5.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.15f), RoundedCornerShape(10.dp))
                        .clickable {
                          pix.qrCode?.let { key ->
                            clipboardManager.setText(AnnotatedString(key))
                            isPixKeyCopied = true
                          }
                        }
                        .padding(12.dp)
                    ) {
                      Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                      ) {
                        Text(
                          text = pix.qrCode?.take(32) + "..." + pix.qrCode?.takeLast(16),
                          style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.SemiBold),
                          maxLines = 1,
                          modifier = Modifier.weight(1f)
                        )
                        Icon(
                          imageVector = Icons.Default.ContentCopy,
                          contentDescription = "Copy key",
                          tint = MaterialTheme.colorScheme.primary,
                          modifier = Modifier.size(18.dp)
                        )
                      }
                    }

                    if (isPixKeyCopied) {
                      Text(
                        text = "✓ Código copiado para área de transferência!",
                        style = MaterialTheme.typography.labelSmall.copy(color = Color(0xFF81C784), fontWeight = FontWeight.Bold),
                        modifier = Modifier.padding(top = 6.dp)
                      )
                    }

                    Spacer(modifier = Modifier.height(24.dp))

                    // WEBHOOK SIMULATION BUTTON
                    Button(
                      onClick = {
                        val simulatedOrder = Order(
                          id = "#${(2085..9999).random()}",
                          customerName = "Guilherme S. Prado",
                          customerPhone = "+55 11 99888-7766",
                          customerAddress = "Alameda Lorena, 1200 - Jardins, SP",
                          orderTime = "Agora",
                          items = listOf(OrderItem("Signature Menu Selection", itemsCount, "R$ ${String.format("%.2f", pricePerItem)}")),
                          notes = "Pago via Pix Mercado Pago ID ${pix.paymentId}",
                          deliveryType = "Rede Uni eats",
                          status = OrderStatus.NOVOS,
                          total = "R$ ${String.format("%.2f", total)}"
                        )
                        onOrderCreated(simulatedOrder)
                        checkoutStep = "success_complete"
                      },
                      modifier = Modifier
                        .fillMaxWidth()
                        .height(50.dp),
                      colors = ButtonDefaults.buttonColors(
                        containerColor = Color(0xFF4CAF50),
                        contentColor = Color.White
                      ),
                      shape = RoundedCornerShape(25.dp)
                    ) {
                      Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(text = "🤝 ", fontSize = 14.sp)
                        Text(
                          text = "MOCK PAGAMENTO APROVADO (WEBHOOK)",
                          style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, letterSpacing = 0.5.sp)
                        )
                      }
                    }
                  }
                }
              }
            }
          }

          "payment_failed" -> {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
              Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                border = BorderStroke(1.dp, Color(0xFFEF5350).copy(alpha = 0.2f)),
                shape = RoundedCornerShape(16.dp)
              ) {
                Column(
                  modifier = Modifier.padding(24.dp),
                  horizontalAlignment = Alignment.CenterHorizontally
                ) {
                  Box(
                    modifier = Modifier
                      .size(64.dp)
                      .background(Color(0xFFEF5350).copy(alpha = 0.12f), CircleShape),
                    contentAlignment = Alignment.Center
                  ) {
                    Icon(
                      imageVector = Icons.Default.Warning,
                      contentDescription = "Warning",
                      tint = Color(0xFFEF5350),
                      modifier = Modifier.size(32.dp)
                    )
                  }

                  Spacer(modifier = Modifier.height(16.dp))

                  Text(
                    text = "Pagamento Recusado",
                    style = MaterialTheme.typography.titleLarge.copy(color = Color(0xFFEF5350), fontWeight = FontWeight.Bold),
                    textAlign = TextAlign.Center
                  )

                  Spacer(modifier = Modifier.height(6.dp))

                  Text(
                    text = when (cardPaymentResponse?.statusDetail) {
                      "cc_rejected_insufficient_amount" -> "Cartão recusado pelo Mercado Pago. Motivo: Saldo insuficiente."
                      "cc_rejected_high_risk" -> "Recusado por motivos de segurança. A inteligência artificial de antifraude Mercado Pago classificou a transação como alto risco."
                      else -> "Erro na comunicação com a API de autorização de crédito."
                    },
                    style = MaterialTheme.typography.bodyMedium,
                    textAlign = TextAlign.Center,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                  )

                  Spacer(modifier = Modifier.height(24.dp))

                  OutlinedButton(
                    onClick = { checkoutStep = "payment" },
                    modifier = Modifier
                      .fillMaxWidth()
                      .height(48.dp),
                    shape = RoundedCornerShape(24.dp),
                    border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary)
                  ) {
                    Text(
                      text = "TENTAR NOVAMENTE COM OUTRO CARTÃO",
                      style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                    )
                  }
                }
              }
            }
          }

          "success_complete" -> {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
              Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)),
                shape = RoundedCornerShape(20.dp)
              ) {
                Column(
                  modifier = Modifier.padding(24.dp),
                  horizontalAlignment = Alignment.CenterHorizontally
                ) {
                  Box(
                    modifier = Modifier
                      .size(64.dp)
                      .background(Color(0xFF81C784).copy(alpha = 0.12f), CircleShape),
                    contentAlignment = Alignment.Center
                  ) {
                    Icon(
                      imageVector = Icons.Default.CheckCircle,
                      contentDescription = "Success",
                      tint = Color(0xFF81C784),
                      modifier = Modifier.size(32.dp)
                    )
                  }

                  Spacer(modifier = Modifier.height(16.dp))

                  Text(
                    text = "Aprovação Confirmada! 🥂",
                    style = MaterialTheme.typography.titleLarge.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold),
                    textAlign = TextAlign.Center
                  )

                  Spacer(modifier = Modifier.height(4.dp))

                  Text(
                    text = "O pagamento foi devidamente processado pela API Mercado Pago. Sua reserva gourmet já foi encaminhada para a cozinha do Chef.",
                    style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)),
                    textAlign = TextAlign.Center
                  )

                  Spacer(modifier = Modifier.height(20.dp))
                  Box(modifier = Modifier.fillMaxWidth().height(0.5.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)))
                  Spacer(modifier = Modifier.height(20.dp))

                  // Transaction Receipt Information
                  Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(text = "ID Mercado Pago", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                    Text(text = "#MP-${(10000000..99999999).random()}", style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Bold))
                  }
                  Spacer(modifier = Modifier.height(6.dp))
                  Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(text = "Método", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                    Text(text = if (selectedPaymentMethod == "pix") "Pix Transferência" else "Cartão de Crédito", style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Bold))
                  }
                  Spacer(modifier = Modifier.height(6.dp))
                  Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(text = "Status", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                    Text(text = "Aprovado", style = MaterialTheme.typography.bodySmall.copy(color = Color(0xFF81C784), fontWeight = FontWeight.Bold))
                  }
                  Spacer(modifier = Modifier.height(6.dp))
                  Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                    Text(text = "Valor Total", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                    Text(text = "R$ ${String.format("%.2f", total)}", style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold))
                  }

                  Spacer(modifier = Modifier.height(28.dp))

                  // Action Buttons
                  Button(
                    onClick = {
                      checkoutStep = "cart"
                      onNavigateToChef()
                    },
                    modifier = Modifier
                      .fillMaxWidth()
                      .height(48.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary),
                    shape = RoundedCornerShape(24.dp)
                  ) {
                    Text(
                      text = "VER NO PAINEL DO CHEF",
                      style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold)
                    )
                  }

                  Spacer(modifier = Modifier.height(10.dp))

                  OutlinedButton(
                    onClick = {
                      checkoutStep = "cart"
                      onClearCart()
                    },
                    modifier = Modifier
                      .fillMaxWidth()
                      .height(48.dp),
                    shape = RoundedCornerShape(24.dp),
                    border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.3f))
                  ) {
                    Text(
                      text = "RETORNAR AO INÍCIO",
                      style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f))
                    )
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

@Composable
fun ChefPanelContent(
  restaurantList: List<Restaurant>,
  orderList: List<Order>,
  selectedCityType: TipoCidade,
  onCityTypeChange: (TipoCidade) -> Unit,
  onUpdateRestaurants: (List<Restaurant>) -> Unit,
  onUpdateOrders: (List<Order>) -> Unit,
  lojistaBalance: Double,
  onUpdateLojistaBalance: (Double) -> Unit,
  lojistaSales: List<SimulatedSaleKotlin>,
  motoboyBalance: Double,
  onUpdateMotoboyBalance: (Double) -> Unit,
  motoboyRoutes: MutableList<CompletedRouteKotlin>,
  parentDeliveryState: String = "idle",
  parentJourneyStep: Int = 1,
  parentSimulationProgress: Float = 0.0f,
  parentRiderLatitude: Double = -23.5614,
  parentRiderLongitude: Double = -46.6559,
  onDeliverySimulationUpdate: (state: String, step: Int, progress: Float, lat: Double, lng: Double) -> Unit = { _, _, _, _, _ -> }
) {
  var activeSubTab by remember { mutableStateOf("Pedidos") } // "Pedidos" (default), "Produto", "Loja", "Cardapio"
  var selectedStatusFilter by remember { mutableStateOf(OrderStatus.NOVOS) }
  var selectedOrderForComanda by remember { mutableStateOf<Order?>(null) }

  // Active overall role of the Admin interface (Chef Lojista, Motoboy Entregador, Owner Super Admin)
  var activeChefRole by remember { mutableStateOf("Chef") } // "Chef", "Motoboy", "Admin"

  // Motoboy (Delivery Module) States synced with Parent
  var deliveryState by remember(parentDeliveryState) { mutableStateOf(parentDeliveryState) } // "idle", "offered", "accepted"
  var activeMotoboySubTab by remember { mutableStateOf("Entregas") } // "Entregas", "Carteira"
  var isWithdrawingMotoboy by remember { mutableStateOf(false) }
  var journeyStep by remember(parentJourneyStep) { mutableStateOf(parentJourneyStep) } // 1 = Retirada, 2 = Preparo, 3 = Rota Cliente
  var simulationProgress by remember(parentSimulationProgress) { mutableStateOf(parentSimulationProgress) }
  var riderLatitude by remember(parentRiderLatitude) { mutableStateOf(parentRiderLatitude) }
  var riderLongitude by remember(parentRiderLongitude) { mutableStateOf(parentRiderLongitude) }

  LaunchedEffect(deliveryState, journeyStep, simulationProgress, riderLatitude, riderLongitude) {
    onDeliverySimulationUpdate(deliveryState, journeyStep, simulationProgress, riderLatitude, riderLongitude)
  }

  // Super Admin (Dono) States
  var isUserVerifiedOwner by remember { mutableStateOf(false) }
  var modoGratuitoSemAssinatura by remember { mutableStateOf(true) }
  var priceBronze by remember { mutableStateOf("129.90") }
  var pricePrata by remember { mutableStateOf("249.90") }
  var priceOuro by remember { mutableStateOf("499.90") }

  // LaunchedEffect for Motoboy Live GPS simulation
  LaunchedEffect(deliveryState, journeyStep) {
    if (deliveryState == "accepted" && journeyStep < 4) {
      while (true) {
        delay(800)
        simulationProgress = (simulationProgress + 0.05f)
        if (simulationProgress > 1.0f) {
          simulationProgress = 0.0f
        }
        val startLat = -23.5614
        val startLng = -46.6559
        val destLat = -23.5732
        val destLng = -46.6698

        if (journeyStep == 1) {
          riderLatitude = startLat - (0.01 * (1.0 - simulationProgress))
          riderLongitude = startLng - (0.01 * (1.0 - simulationProgress))
        } else if (journeyStep == 3) {
          riderLatitude = startLat + (destLat - startLat) * simulationProgress
          riderLongitude = startLng + (destLng - startLng) * simulationProgress
        }
      }
    }
  }
  
  // Fields for new product
  var selectedRestId by remember { mutableStateOf(restaurantList.firstOrNull()?.id ?: "") }
  var dishName by remember { mutableStateOf("") }
  var dishPrice by remember { mutableStateOf("") }
  var dishDesc by remember { mutableStateOf("") }

  // Fields for new store
  var storeName by remember { mutableStateOf("") }
  var storeTag by remember { mutableStateOf("") }
  var storeCategory by remember { mutableStateOf("Hambúrguer") } // Default to hamburger
  var selectedPresetImage by remember { mutableStateOf(R.drawable.img_burger_1783375467965) } // Default preset fallback
  
  // Fields for settings (Configurações do Lojista)
  var configRestName by remember { mutableStateOf("UniEats Gourmet") }
  var configRestPhone by remember { mutableStateOf("(11) 98765-4321") }
  var configRestSpecialty by remember { mutableStateOf("Alta Gastronomia") }
  var configRestPrepTime by remember { mutableStateOf("25-35 min") }
  var configLogistics by remember { mutableStateOf("unieats") } // "proprio" or "unieats"
  var mpConnected by remember { mutableStateOf(false) }
  var mpConnecting by remember { mutableStateOf(false) }
  
  // Dynamic feedback message
  var successMessage by remember { mutableStateOf<String?>(null) }

  // Set default selected preset image when category changes
  LaunchedEffect(storeCategory) {
    selectedPresetImage = when (storeCategory) {
      "Hambúrguer" -> R.drawable.img_burger_1783375467965
      "Pizza" -> R.drawable.img_pizza_1783375478991
      "Pastel" -> R.drawable.img_pastel_1783375489380
      else -> R.drawable.img_luxe_banner_1783374585687
    }
  }

  // Clear success toast after 3.5 seconds
  LaunchedEffect(successMessage) {
    if (successMessage != null) {
      delay(3500)
      successMessage = null
    }
  }

  Box(modifier = Modifier.fillMaxSize()) {
    LazyColumn(
      modifier = Modifier
        .fillMaxSize()
        .padding(horizontal = 20.dp),
      contentPadding = PaddingValues(bottom = 100.dp)
    ) {
      item {
        Spacer(modifier = Modifier.height(24.dp))
        Text(
          text = if (activeChefRole == "Chef") "Portal do Chef" 
                 else if (activeChefRole == "Motoboy") "Painel do Motoboy" 
                 else "Painel do Proprietário",
          style = MaterialTheme.typography.displayMedium.copy(
            color = MaterialTheme.colorScheme.primary,
            fontWeight = FontWeight.Light,
            fontSize = 28.sp,
            letterSpacing = 1.sp
          )
        )
        Text(
          text = if (activeChefRole == "Chef") "PAINEL DE EXPANSÃO GASTRONÔMICA & GESTÃO"
                 else if (activeChefRole == "Motoboy") "SISTEMA DE LOGÍSTICA & ENTREGAS UNI EATS"
                 else "CONTRATO INTELIGENTE & CONTROLE DE MENSALIDADES",
          style = MaterialTheme.typography.labelSmall.copy(
            color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f),
            fontWeight = FontWeight.Bold,
            letterSpacing = 2.sp
          ),
          modifier = Modifier.padding(top = 4.dp, bottom = 16.dp)
        )

        // ROLE SELECTOR ROW (Material Design 3 Segmented Switch)
        Row(
          modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 20.dp)
            .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(12.dp))
            .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.1f), RoundedCornerShape(12.dp))
            .padding(4.dp),
          horizontalArrangement = Arrangement.SpaceBetween
        ) {
          listOf(
            "Chef" to "Lojista",
            "Motoboy" to "Motoboy",
            "Admin" to "Super Admin"
          ).forEach { (role, label) ->
            val isSelected = activeChefRole == role
            Box(
              modifier = Modifier
                .weight(1f)
                .clip(RoundedCornerShape(8.dp))
                .background(if (isSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.15f) else Color.Transparent)
                .border(
                  width = if (isSelected) 1.dp else 0.dp,
                  color = if (isSelected) MaterialTheme.colorScheme.primary else Color.Transparent,
                  shape = RoundedCornerShape(8.dp)
                )
                .clickable { activeChefRole = role }
                .padding(vertical = 10.dp),
              contentAlignment = Alignment.Center
            ) {
              Text(
                text = label,
                style = MaterialTheme.typography.labelMedium.copy(
                  color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                  fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                  fontSize = 11.sp
                )
              )
            }
          }
        }
      }

      // High fidelity feedback toast if active
      successMessage?.let { msg ->
        item {
          Box(
            modifier = Modifier
              .fillMaxWidth()
              .padding(vertical = 12.dp)
              .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
              .border(1.dp, MaterialTheme.colorScheme.primary, RoundedCornerShape(12.dp))
              .padding(16.dp),
            contentAlignment = Alignment.Center
          ) {
            Text(
              text = msg,
              style = MaterialTheme.typography.bodyLarge.copy(
                color = MaterialTheme.colorScheme.primary,
                fontWeight = FontWeight.Bold
              ),
              textAlign = TextAlign.Center
            )
          }
        }
      }

      if (activeChefRole == "Chef") {
        // Premium Segmented Switch Tab with 4 positions
        item {
          Row(
            modifier = Modifier
              .fillMaxWidth()
              .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(14.dp))
              .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f), RoundedCornerShape(14.dp))
              .padding(4.dp),
            horizontalArrangement = Arrangement.SpaceBetween
          ) {
            listOf(
              "Pedidos" to "Pedidos",
              "Produto" to "Adicionar",
              "Loja" to "Loja",
              "Cardapio" to "Menus",
              "Config" to "Ajustes",
              "Financas" to "Extrato"
            ).forEach { (key, label) ->
              val isSelected = activeSubTab == key
              Box(
                modifier = Modifier
                  .weight(1f)
                  .clip(RoundedCornerShape(10.dp))
                  .background(if (isSelected) MaterialTheme.colorScheme.primary else Color.Transparent)
                  .clickable { activeSubTab = key }
                  .padding(vertical = 10.dp),
                contentAlignment = Alignment.Center
              ) {
                Text(
                  text = label,
                  style = MaterialTheme.typography.labelMedium.copy(
                    color = if (isSelected) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                    fontSize = 10.sp
                  )
                )
              }
            }
          }
          Spacer(modifier = Modifier.height(24.dp))
        }
      }

      if (activeChefRole == "Chef") {
        when (activeSubTab) {
          "Pedidos" -> {
          // 1. STATS FILTER CHIPS FOR LIVE KITCHEN
          item {
            Row(
              modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
              horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
              listOf(
                OrderStatus.NOVOS to "Novos",
                OrderStatus.PREPARO to "Preparo",
                OrderStatus.PRONTOS to "Prontos"
              ).forEach { (status, label) ->
                val count = orderList.count { it.status == status }
                val isSelected = selectedStatusFilter == status
                
                Box(
                  modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(12.dp))
                    .background(
                      if (isSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.15f)
                      else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f)
                    )
                    .border(
                      width = if (isSelected) 1.5.dp else 1.dp,
                      color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.15f),
                      shape = RoundedCornerShape(12.dp)
                    )
                    .clickable { selectedStatusFilter = status }
                    .padding(vertical = 12.dp, horizontal = 4.dp),
                  contentAlignment = Alignment.Center
                ) {
                  Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                      text = label.uppercase(),
                      style = MaterialTheme.typography.labelSmall.copy(
                        color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 1.sp,
                        fontSize = 10.sp
                      )
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                      text = count.toString(),
                      style = MaterialTheme.typography.titleMedium.copy(
                        color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
                        fontWeight = FontWeight.Bold
                      )
                    )
                  }
                }
              }
            }
          }

          // 2. ACTIVE ORDERS LIST
          val filteredOrders = orderList.filter { it.status == selectedStatusFilter }
          
          if (filteredOrders.isEmpty()) {
            item {
              Box(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(vertical = 48.dp, horizontal = 16.dp),
                contentAlignment = Alignment.Center
              ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                  Text(
                    text = "🍳",
                    fontSize = 44.sp,
                    modifier = Modifier.padding(bottom = 16.dp)
                  )
                  Text(
                    text = "Nenhum pedido nesta etapa",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    color = MaterialTheme.colorScheme.onSurface
                  )
                  Text(
                    text = "Novos pedidos aparecerão em tempo real conforme as comandas forem abertas pelos clientes.",
                    style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(top = 4.dp, start = 20.dp, end = 20.dp)
                  )
                }
              }
            }
          } else {
            items(filteredOrders) { order ->
              Card(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(vertical = 8.dp)
                  .testTag("order_card_${order.id.replace("#", "")}"),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
              ) {
                Column(modifier = Modifier.padding(16.dp)) {
                  // HEADER: Order ID, Time and Delivery Fleet Type
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                      Text(
                        text = order.id,
                        style = MaterialTheme.typography.titleLarge.copy(
                          color = MaterialTheme.colorScheme.primary,
                          fontWeight = FontWeight.Bold,
                          letterSpacing = 0.5.sp,
                          fontSize = 18.sp
                        )
                      )
                      Spacer(modifier = Modifier.width(8.dp))
                      Text(
                        text = "• ${order.orderTime}",
                        style = MaterialTheme.typography.bodySmall.copy(
                          color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                          fontWeight = FontWeight.Medium
                        )
                      )
                    }

                    // Delivery Tag
                    val isAppFleet = order.deliveryType == "Rede Uni eats"
                    Box(
                      modifier = Modifier
                        .clip(RoundedCornerShape(8.dp))
                        .background(
                          if (isAppFleet) MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)
                          else Color(0xFF81C784).copy(alpha = 0.1f)
                        )
                        .border(
                          width = 0.5.dp,
                          color = if (isAppFleet) MaterialTheme.colorScheme.primary else Color(0xFF81C784),
                          shape = RoundedCornerShape(8.dp)
                        )
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                      Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                          text = if (isAppFleet) "🛵 " else "🏰 ",
                          fontSize = 10.sp
                        )
                        Text(
                          text = order.deliveryType.uppercase(),
                          style = MaterialTheme.typography.labelSmall.copy(
                            color = if (isAppFleet) MaterialTheme.colorScheme.primary else Color(0xFF81C784),
                            fontWeight = FontWeight.Bold,
                            fontSize = 8.sp,
                            letterSpacing = 0.5.sp
                          )
                        )
                      }
                    }
                  }

                  Spacer(modifier = Modifier.height(12.dp))
                  Box(modifier = Modifier.fillMaxWidth().height(0.5.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)))
                  Spacer(modifier = Modifier.height(12.dp))

                  // CLIENT DETAILS
                  Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(text = "👤", fontSize = 12.sp, modifier = Modifier.padding(end = 6.dp))
                    Text(
                      text = "${order.customerName} (${order.customerPhone})",
                      style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                    )
                  }
                  
                  Row(
                    modifier = Modifier.padding(top = 4.dp),
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Text(text = "📍", fontSize = 12.sp, modifier = Modifier.padding(end = 6.dp))
                    Text(
                      text = order.customerAddress,
                      style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)),
                      maxLines = 1,
                      overflow = TextOverflow.Ellipsis
                    )
                  }

                  Spacer(modifier = Modifier.height(12.dp))

                  // ORDER ITEMS GOURMET LIST
                  Box(
                    modifier = Modifier
                      .fillMaxWidth()
                      .background(MaterialTheme.colorScheme.background.copy(alpha = 0.4f), RoundedCornerShape(12.dp))
                      .padding(12.dp)
                  ) {
                    Column {
                      order.items.forEach { item ->
                        Row(
                          modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 4.dp),
                          horizontalArrangement = Arrangement.SpaceBetween,
                          verticalAlignment = Alignment.CenterVertically
                        ) {
                          Row(modifier = Modifier.weight(1f)) {
                            Text(
                              text = "${item.quantity}x",
                              style = MaterialTheme.typography.bodyMedium.copy(
                                color = MaterialTheme.colorScheme.primary,
                                fontWeight = FontWeight.Bold
                              ),
                              modifier = Modifier.padding(end = 8.dp)
                            )
                            Text(
                              text = item.name,
                              style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                            )
                          }
                          Text(
                            text = item.price,
                            style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.SemiBold)
                          )
                        }
                      }
                    }
                  }

                  // CLIENT/CHEF OBS
                  if (order.notes.isNotBlank()) {
                    Box(
                      modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 10.dp)
                        .background(Color(0xFFFFB74D).copy(alpha = 0.08f), RoundedCornerShape(10.dp))
                        .border(0.5.dp, Color(0xFFFFB74D).copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                        .padding(10.dp)
                    ) {
                      Row {
                        Text(text = "🗒️ ", fontSize = 12.sp)
                        Text(
                          text = "Obs: \"${order.notes}\"",
                          style = MaterialTheme.typography.bodySmall.copy(
                            color = Color(0xFFFFB74D),
                            fontWeight = FontWeight.Medium
                          )
                        )
                      }
                    }
                  }

                  Spacer(modifier = Modifier.height(14.dp))
                  
                  // Total price display
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Text(
                      text = "Total Líquido",
                      style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                    )
                    Text(
                      text = order.total,
                      style = MaterialTheme.typography.titleMedium.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Black)
                    )
                  }

                  Spacer(modifier = Modifier.height(16.dp))

                  // ACTION BUTTONS FOR AGENT USABILITY
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                  ) {
                    // "Comanda" thermal generator button
                    OutlinedButton(
                      onClick = { selectedOrderForComanda = order },
                      modifier = Modifier
                        .weight(1f)
                        .height(48.dp),
                      shape = RoundedCornerShape(12.dp),
                      border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.4f))
                    ) {
                      Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(text = "🧾 ", fontSize = 12.sp)
                        Text(
                          text = "VER COMANDA",
                          style = MaterialTheme.typography.labelSmall.copy(
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.primary,
                            letterSpacing = 0.5.sp
                          )
                        )
                      }
                    }

                    // Main progression action button
                    Button(
                      onClick = {
                        val updated = orderList.map { item ->
                          if (item.id == order.id) {
                            when (order.status) {
                              OrderStatus.NOVOS -> {
                                successMessage = "👨‍🍳 Pedido ${order.id} aceito. Iniciando preparação gourmet!"
                                item.copy(status = OrderStatus.PREPARO)
                              }
                              OrderStatus.PREPARO -> {
                                successMessage = "🚀 Alerta enviado! Entregador notificado para o pedido ${order.id}."
                                item.copy(status = OrderStatus.PRONTOS)
                              }
                              OrderStatus.PRONTOS -> {
                                successMessage = "🏁 Pedido ${order.id} concluído e arquivado com sucesso!"
                                item.copy(status = OrderStatus.NOVOS) // Loop back or we can filter it out later
                              }
                            }
                          } else {
                            item
                          }
                        }
                        
                        // If it was PRONTOS, we can remove it or just cycle it
                        if (order.status == OrderStatus.PRONTOS) {
                          onUpdateOrders(orderList.filter { it.id != order.id })
                        } else {
                          onUpdateOrders(updated)
                        }
                      },
                      modifier = Modifier
                        .weight(1.2f)
                        .height(48.dp),
                      colors = ButtonDefaults.buttonColors(
                        containerColor = when (order.status) {
                          OrderStatus.NOVOS -> MaterialTheme.colorScheme.primary
                          OrderStatus.PREPARO -> Color(0xFF4CAF50)
                          OrderStatus.PRONTOS -> Color(0xFF2196F3)
                        },
                        contentColor = Color.White
                      ),
                      shape = RoundedCornerShape(12.dp)
                    ) {
                      Text(
                        text = when (order.status) {
                          OrderStatus.NOVOS -> "ACEITAR E INICIAR"
                          OrderStatus.PREPARO -> "CHAMAR ENTREGADOR"
                          OrderStatus.PRONTOS -> "CONCLUIR PEDIDO"
                        },
                        style = MaterialTheme.typography.labelSmall.copy(
                          fontWeight = FontWeight.Bold,
                          letterSpacing = 0.5.sp,
                          fontSize = 10.sp
                        )
                      )
                    }
                  }
                }
              }
            }
          }
        }

        "Produto" -> {
          item {
            Text(
              text = "Adicionar Produto Gourmet",
              style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
              modifier = Modifier.padding(bottom = 12.dp)
            )
          }

          // Restaurant Selector Cards
          item {
            Text(
              text = "Selecione o Estabelecimento:",
              style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)),
              modifier = Modifier.padding(bottom = 8.dp)
            )
            
            Row(
              modifier = Modifier
                .fillMaxWidth()
                .horizontalScroll(rememberScrollState())
                .padding(vertical = 4.dp),
              horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
              val relevantRests = restaurantList.filter { it.category in listOf("Hambúrguer", "Pizza", "Pastel", "Gourmet", "Massas") }
              val displayList = if (relevantRests.isEmpty()) restaurantList else relevantRests
              
              // Auto select first if selectedRestId is not valid
              if (selectedRestId !in displayList.map { it.id }) {
                displayList.firstOrNull()?.let { selectedRestId = it.id }
              }

              displayList.forEach { rest ->
                val isSelected = selectedRestId == rest.id
                Card(
                  modifier = Modifier
                    .width(160.dp)
                    .clickable { selectedRestId = rest.id },
                  shape = RoundedCornerShape(12.dp),
                  border = BorderStroke(
                    width = if (isSelected) 2.dp else 1.dp,
                    color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)
                  ),
                  colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
                ) {
                  Column(modifier = Modifier.padding(12.dp)) {
                    Text(
                      text = rest.name,
                      style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onSurface),
                      maxLines = 1,
                      overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                      text = rest.category.uppercase(),
                      style = MaterialTheme.typography.labelSmall.copy(
                        color = MaterialTheme.colorScheme.primary,
                        fontSize = 8.sp,
                        letterSpacing = 1.sp
                      )
                    )
                  }
                }
              }
            }
            Spacer(modifier = Modifier.height(16.dp))
          }

          // Dish Name Input
          item {
            OutlinedTextField(
              value = dishName,
              onValueChange = { dishName = it },
              label = { Text("Nome do Prato / Produto") },
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
                .testTag("chef_dish_name"),
              colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
              ),
              shape = RoundedCornerShape(12.dp),
              singleLine = true
            )
          }

          // Price Input
          item {
            OutlinedTextField(
              value = dishPrice,
              onValueChange = { dishPrice = it },
              label = { Text("Preço (Ex: R$ 45,00)") },
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
                .testTag("chef_dish_price"),
              colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
              ),
              shape = RoundedCornerShape(12.dp),
              singleLine = true
            )
          }

          // Description Input
          item {
            OutlinedTextField(
              value = dishDesc,
              onValueChange = { dishDesc = it },
              label = { Text("Descrição e Ingredientes Nobres") },
              modifier = Modifier
                .fillMaxWidth()
                .height(110.dp)
                .padding(vertical = 8.dp)
                .testTag("chef_dish_desc"),
              colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
              ),
              shape = RoundedCornerShape(12.dp),
              maxLines = 4
            )
          }

          // Submit Button
          item {
            Spacer(modifier = Modifier.height(16.dp))
            Button(
              onClick = {
                if (dishName.isBlank() || dishPrice.isBlank()) {
                  successMessage = "❌ Por favor, preencha o nome e preço do prato."
                  return@Button
                }
                val updated = restaurantList.map { rest ->
                  if (rest.id == selectedRestId) {
                    rest.copy(
                      signatureDishes = rest.signatureDishes + Dish(
                        name = dishName,
                        price = if (dishPrice.startsWith("R$")) dishPrice else "R$ $dishPrice",
                        description = dishDesc.ifBlank { "Receita artesanal exclusiva preparada por nossos chefs parceiros." }
                      )
                    )
                  } else {
                    rest
                  }
                }
                onUpdateRestaurants(updated)
                successMessage = "✨ '${dishName}' foi adicionado com sucesso ao cardápio!"
                dishName = ""
                dishPrice = ""
                dishDesc = ""
              },
              modifier = Modifier
                .fillMaxWidth()
                .height(54.dp)
                .testTag("chef_dish_submit"),
              colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary
              ),
              shape = RoundedCornerShape(27.dp)
            ) {
              Text(
                text = "CADASTRAR PRODUTO",
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
              )
            }
          }
        }

        "Loja" -> {
          item {
            Text(
              text = "Cadastrar Novo Estabelecimento",
              style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
              modifier = Modifier.padding(bottom = 12.dp)
            )
          }

          // Category Type selector
          item {
            Text(
              text = "Selecione a Categoria:",
              style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)),
              modifier = Modifier.padding(bottom = 8.dp)
            )

            Row(
              modifier = Modifier.fillMaxWidth(),
              horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
              listOf(
                "Hambúrguer" to "🍔 Burger",
                "Pizza" to "🍕 Pizza",
                "Pastel" to "🥟 Pastel"
              ).forEach { (cat, label) ->
                val isSelected = storeCategory == cat
                Box(
                  modifier = Modifier
                    .weight(1f)
                    .clip(RoundedCornerShape(12.dp))
                    .background(if (isSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.15f) else MaterialTheme.colorScheme.surface)
                    .border(
                      width = if (isSelected) 2.dp else 1.dp,
                      color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.2f),
                      shape = RoundedCornerShape(12.dp)
                    )
                    .clickable { storeCategory = cat }
                    .padding(vertical = 12.dp),
                  contentAlignment = Alignment.Center
                ) {
                  Text(
                    text = label,
                    style = MaterialTheme.typography.labelMedium.copy(
                      color = if (isSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                      fontWeight = FontWeight.Bold
                    )
                  )
                }
              }
            }
            Spacer(modifier = Modifier.height(16.dp))
          }

          // Store Name Input
          item {
            OutlinedTextField(
              value = storeName,
              onValueChange = { storeName = it },
              label = { Text("Nome da Loja (Ex: Burger de l'Est)") },
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
                .testTag("chef_store_name"),
              colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
              ),
              shape = RoundedCornerShape(12.dp),
              singleLine = true
            )
          }

          // Special Tag Input
          item {
            OutlinedTextField(
              value = storeTag,
              onValueChange = { storeTag = it },
              label = { Text("Selo Especial (Ex: Gourmet Wagyu, Forno a Lenha)") },
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
                .testTag("chef_store_tag"),
              colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = MaterialTheme.colorScheme.primary,
                unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
              ),
              shape = RoundedCornerShape(12.dp),
              singleLine = true
            )
          }

          // Banner Premium Preview Preset
          item {
            Text(
              text = "Visual da Capa Premium (Gerada por IA):",
              style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)),
              modifier = Modifier.padding(top = 12.dp, bottom = 8.dp)
            )

            Card(
              modifier = Modifier
                .fillMaxWidth()
                .height(130.dp),
              shape = RoundedCornerShape(16.dp),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.3f))
            ) {
              Box(modifier = Modifier.fillMaxSize()) {
                if (selectedPresetImage != 0) {
                  Image(
                    painter = painterResource(id = selectedPresetImage),
                    contentDescription = "Visual Preset Capa",
                    contentScale = ContentScale.Crop,
                    modifier = Modifier.fillMaxSize()
                  )
                } else {
                  Box(modifier = Modifier.fillMaxSize().background(Color(0xFF222222)))
                }
                Box(
                  modifier = Modifier
                    .fillMaxSize()
                    .background(
                      Brush.verticalGradient(
                        colors = listOf(Color.Transparent, Color.Black.copy(alpha = 0.7f))
                      )
                    )
                )
                Text(
                  text = "Preset Ativo: $storeCategory Premium",
                  style = MaterialTheme.typography.labelMedium.copy(color = Color.White, fontWeight = FontWeight.Bold),
                  modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(12.dp)
                )
              }
            }
            Spacer(modifier = Modifier.height(24.dp))
          }

          // Submit Button
          item {
            Button(
              onClick = {
                if (storeName.isBlank()) {
                  successMessage = "❌ Por favor, informe o nome do estabelecimento."
                  return@Button
                }
                val newId = (restaurantList.size + 1).toString()
                val newStore = Restaurant(
                  id = newId,
                  name = storeName,
                  category = storeCategory,
                  rating = 4.8,
                  distance = "${(1..4).random()}.${(0..9).random()} km",
                  deliveryTime = "${(15..45).random()} min",
                  deliveryFee = if ((0..1).random() == 0) "Grátis" else "R$ ${(8..16).random()},00",
                  tag = storeTag.ifBlank { "Artesanal de Luxo" },
                  imageResId = selectedPresetImage,
                  signatureDishes = emptyList()
                )
                onUpdateRestaurants(restaurantList + newStore)
                successMessage = "🏰 '${storeName}' cadastrado com sucesso! Já está listado na categoria '$storeCategory'."
                selectedRestId = newId // Switch selector to the newly created store
                storeName = ""
                storeTag = ""
              },
              modifier = Modifier
                .fillMaxWidth()
                .height(54.dp)
                .testTag("chef_store_submit"),
              colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary
              ),
              shape = RoundedCornerShape(27.dp)
            ) {
              Text(
                text = "REGISTRAR ESTABELECIMENTO",
                style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
              )
            }
          }
        }

        "Cardapio" -> {
          item {
            Text(
              text = "Gerenciamento de Cardápio Ativo",
              style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
              modifier = Modifier.padding(bottom = 12.dp)
            )
          }

          val editableRests = restaurantList.filter { it.category in listOf("Hambúrguer", "Pizza", "Pastel", "Gourmet", "Massas") }
          val displayList = if (editableRests.isEmpty()) restaurantList else editableRests

          if (displayList.isEmpty()) {
            item {
              Text(text = "Nenhum estabelecimento cadastrado.", style = MaterialTheme.typography.bodyMedium)
            }
          } else {
            items(displayList) { rest ->
              Card(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(vertical = 8.dp),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.1f))
              ) {
                Column(modifier = Modifier.padding(16.dp)) {
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Column {
                      Text(text = rest.name, style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold))
                      Text(text = rest.category.uppercase(), style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.primary))
                    }
                    
                    // Delete shop button
                    Text(
                      text = "Remover Loja",
                      style = MaterialTheme.typography.labelSmall.copy(color = Color(0xFFEF5350), fontWeight = FontWeight.Bold),
                      modifier = Modifier.clickable {
                        onUpdateRestaurants(restaurantList.filter { it.id != rest.id })
                        successMessage = "🗑️ Loja '${rest.name}' removida com sucesso."
                      }
                    )
                  }

                  Spacer(modifier = Modifier.height(12.dp))
                  Box(modifier = Modifier.fillMaxWidth().height(0.5.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)))
                  Spacer(modifier = Modifier.height(8.dp))

                  Text(
                    text = "Pratos do Menu (${rest.signatureDishes.size}):",
                    style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                  )

                  if (rest.signatureDishes.isEmpty()) {
                    Text(
                      text = "Sem pratos adicionados ainda.",
                      style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)),
                      modifier = Modifier.padding(vertical = 4.dp)
                    )
                  } else {
                    rest.signatureDishes.forEach { dish ->
                      Row(
                        modifier = Modifier
                          .fillMaxWidth()
                          .padding(vertical = 6.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                      ) {
                        Column(modifier = Modifier.weight(1f)) {
                          Text(text = dish.name, style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                          Text(text = dish.price, style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold))
                        }
                        
                        // Delete item button
                        Icon(
                          imageVector = Icons.Default.Close,
                          contentDescription = "Remover prato",
                          tint = Color(0xFFEF5350),
                          modifier = Modifier
                            .size(18.dp)
                            .clickable {
                              val updatedDishes = rest.signatureDishes.filter { it.name != dish.name }
                              onUpdateRestaurants(
                                restaurantList.map { r ->
                                  if (r.id == rest.id) r.copy(signatureDishes = updatedDishes) else r
                                }
                              )
                              successMessage = "🗑️ Prato '${dish.name}' removido."
                            }
                        )
                      }
                    }
                  }
                }
              }
            }
          }
        }

        "Config" -> {
          item {
            Text(
              text = "Configurações do Estabelecimento",
              style = MaterialTheme.typography.titleMedium.copy(
                color = MaterialTheme.colorScheme.onBackground,
                fontWeight = FontWeight.SemiBold,
                fontSize = 18.sp
              ),
              modifier = Modifier.padding(bottom = 4.dp)
            )
            Text(
              text = "Gerencie o perfil público, a logística de entrega e conexões financeiras.",
              style = MaterialTheme.typography.bodySmall.copy(
                color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.5f)
              ),
              modifier = Modifier.padding(bottom = 16.dp)
            )
          }

          // SECTION 1: Perfil do Estabelecimento
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
            ) {
              Column(modifier = Modifier.padding(16.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Text(text = "🏰", fontSize = 16.sp, modifier = Modifier.padding(end = 8.dp))
                  Text(
                    text = "Perfil do Estabelecimento",
                    style = MaterialTheme.typography.titleSmall.copy(
                      fontWeight = FontWeight.Bold,
                      color = MaterialTheme.colorScheme.primary
                    )
                  )
                }
                Spacer(modifier = Modifier.height(16.dp))

                // Nome do Restaurante
                OutlinedTextField(
                  value = configRestName,
                  onValueChange = { configRestName = it },
                  label = { Text("Nome do Restaurante") },
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp)
                    .testTag("config_restaurant_name"),
                  colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MaterialTheme.colorScheme.primary,
                    unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                    focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                    unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
                  ),
                  shape = RoundedCornerShape(12.dp),
                  singleLine = true
                )

                // Telefone
                OutlinedTextField(
                  value = configRestPhone,
                  onValueChange = { configRestPhone = it },
                  label = { Text("Telefone de Contato") },
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp)
                    .testTag("config_restaurant_phone"),
                  colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MaterialTheme.colorScheme.primary,
                    unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                    focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                    unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
                  ),
                  shape = RoundedCornerShape(12.dp),
                  singleLine = true
                )

                // Especialidade/Culinária
                OutlinedTextField(
                  value = configRestSpecialty,
                  onValueChange = { configRestSpecialty = it },
                  label = { Text("Especialidade / Tipo de Culinária") },
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp)
                    .testTag("config_restaurant_specialty"),
                  colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MaterialTheme.colorScheme.primary,
                    unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                    focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                    unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
                  ),
                  shape = RoundedCornerShape(12.dp),
                  singleLine = true
                )

                // Tempo Médio de Preparo
                OutlinedTextField(
                  value = configRestPrepTime,
                  onValueChange = { configRestPrepTime = it },
                  label = { Text("Tempo Médio de Preparo (Ex: 30-45 min)") },
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp)
                    .testTag("config_restaurant_prep_time"),
                  colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor = MaterialTheme.colorScheme.primary,
                    unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.3f),
                    focusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.2f),
                    unfocusedContainerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.1f)
                  ),
                  shape = RoundedCornerShape(12.dp),
                  singleLine = true
                )
              }
            }
          }

          // SECTION 2: Modelo de Logística e Entrega
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
            ) {
              Column(modifier = Modifier.padding(16.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Text(text = "🛵", fontSize = 16.sp, modifier = Modifier.padding(end = 8.dp))
                  Text(
                    text = "Modelo de Logística e Entrega",
                    style = MaterialTheme.typography.titleSmall.copy(
                      fontWeight = FontWeight.Bold,
                      color = MaterialTheme.colorScheme.primary
                    )
                  )
                }
                Spacer(modifier = Modifier.height(14.dp))

                // Custom Card Selector 1: Entregadores Próprios
                val isProprioSelected = configLogistics == "proprio"
                Box(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(
                      if (isProprioSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)
                      else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f)
                    )
                    .border(
                      width = if (isProprioSelected) 1.5.dp else 1.dp,
                      color = if (isProprioSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.15f),
                      shape = RoundedCornerShape(12.dp)
                    )
                    .clickable { configLogistics = "proprio" }
                    .padding(16.dp)
                ) {
                  Row(verticalAlignment = Alignment.CenterVertically) {
                    RadioButton(
                      selected = isProprioSelected,
                      onClick = { configLogistics = "proprio" },
                      colors = RadioButtonDefaults.colors(selectedColor = MaterialTheme.colorScheme.primary)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Column {
                      Text(
                        text = "Utilizar Entregadores Próprios (Fixo)",
                        style = MaterialTheme.typography.bodyMedium.copy(
                          fontWeight = FontWeight.Bold,
                          color = if (isProprioSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
                        )
                      )
                      Text(
                        text = "Logística de entrega gerenciada internamente pela sua equipe.",
                        style = MaterialTheme.typography.bodySmall.copy(
                          color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                      )
                    }
                  }
                }

                // Custom Card Selector 2: Rede UniEats
                val isUnieatsSelected = configLogistics == "unieats"
                Box(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(
                      if (isUnieatsSelected) MaterialTheme.colorScheme.primary.copy(alpha = 0.1f)
                      else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.3f)
                    )
                    .border(
                      width = if (isUnieatsSelected) 1.5.dp else 1.dp,
                      color = if (isUnieatsSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.15f),
                      shape = RoundedCornerShape(12.dp)
                    )
                    .clickable { configLogistics = "unieats" }
                    .padding(16.dp)
                ) {
                  Row(verticalAlignment = Alignment.CenterVertically) {
                    RadioButton(
                      selected = isUnieatsSelected,
                      onClick = { configLogistics = "unieats" },
                      colors = RadioButtonDefaults.colors(selectedColor = MaterialTheme.colorScheme.primary)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Column {
                      Text(
                        text = "Rede de Motoboys Uni eats",
                        style = MaterialTheme.typography.bodyMedium.copy(
                          fontWeight = FontWeight.Bold,
                          color = if (isUnieatsSelected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
                        )
                      )
                      Text(
                        text = "Rastreamento por GPS em tempo real integrado no ecossistema.",
                        style = MaterialTheme.typography.bodySmall.copy(
                          color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                        )
                      )
                    }
                  }
                }
              }
            }
          }

          // SECTION 3: Integração Financeira Mercado Pago (Split Avançado)
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
            ) {
              val scope = rememberCoroutineScope()
              Column(modifier = Modifier.padding(16.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Text(text = "💳", fontSize = 16.sp, modifier = Modifier.padding(end = 8.dp))
                  Text(
                    text = "Integração Financeira Mercado Pago",
                    style = MaterialTheme.typography.titleSmall.copy(
                      fontWeight = FontWeight.Bold,
                      color = MaterialTheme.colorScheme.primary
                    )
                  )
                }
                Spacer(modifier = Modifier.height(14.dp))

                Box(
                  modifier = Modifier
                    .fillMaxWidth()
                    .background(
                      MaterialTheme.colorScheme.primary.copy(alpha = 0.04f),
                      RoundedCornerShape(12.dp)
                    )
                    .border(
                      1.dp,
                      MaterialTheme.colorScheme.primary.copy(alpha = 0.1f),
                      RoundedCornerShape(12.dp)
                    )
                    .padding(16.dp)
                ) {
                  Column {
                    Row(
                      modifier = Modifier.fillMaxWidth(),
                      horizontalArrangement = Arrangement.SpaceBetween,
                      verticalAlignment = Alignment.CenterVertically
                    ) {
                      Text(
                        text = "Gateway de Pagamentos",
                        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                      )
                      
                      // Status Text
                      if (mpConnected) {
                        Box(
                          modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(Color(0xFF2E7D32).copy(alpha = 0.15f))
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                          Text(
                            text = "Status: Conectado",
                            style = MaterialTheme.typography.labelSmall.copy(
                              color = Color(0xFF81C784),
                              fontWeight = FontWeight.Bold,
                              fontSize = 9.sp
                            )
                          )
                        }
                      } else {
                        Box(
                          modifier = Modifier
                            .clip(RoundedCornerShape(6.dp))
                            .background(MaterialTheme.colorScheme.outline.copy(alpha = 0.1f))
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                        ) {
                          Text(
                            text = "Status: Não Conectado",
                            style = MaterialTheme.typography.labelSmall.copy(
                              color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                              fontWeight = FontWeight.Bold,
                              fontSize = 9.sp
                            )
                          )
                        }
                      }
                    }

                    Spacer(modifier = Modifier.height(10.dp))
                    Text(
                      text = if (mpConnected) "Conta Ativa: aquilaa043@gmail.com\nSplit de Pagamento ativado para transações instantâneas automatizadas."
                             else "Conecte sua conta Mercado Pago para transacionar valores com split automatizado.",
                      style = MaterialTheme.typography.bodySmall.copy(
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                      )
                    )

                    Spacer(modifier = Modifier.height(20.dp))

                    if (mpConnecting) {
                      Box(
                        modifier = Modifier.fillMaxWidth(),
                        contentAlignment = Alignment.Center
                      ) {
                        CircularProgressIndicator(
                          color = MaterialTheme.colorScheme.primary,
                          modifier = Modifier.size(24.dp),
                          strokeWidth = 2.dp
                        )
                      }
                    } else {
                      // Mercado Pago button adapted to design
                      Button(
                        onClick = {
                          if (mpConnected) {
                            mpConnected = false
                            successMessage = "🔌 Conta Mercado Pago desconectada com sucesso."
                          } else {
                            mpConnecting = true
                            scope.launch {
                              delay(1500)
                              mpConnecting = false
                              mpConnected = true
                              successMessage = "✓ Conta Mercado Pago conectada com sucesso! (aquilaa043@gmail.com)"
                            }
                          }
                        },
                        modifier = Modifier.fillMaxWidth().height(48.dp),
                        shape = RoundedCornerShape(24.dp),
                        colors = ButtonDefaults.buttonColors(
                          containerColor = if (mpConnected) Color(0xFFEF5350).copy(alpha = 0.1f) else Color(0xFF009EE3),
                          contentColor = if (mpConnected) Color(0xFFEF5350) else Color.White
                        ),
                        border = if (mpConnected) BorderStroke(1.dp, Color(0xFFEF5350)) else null
                      ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                          if (!mpConnected) {
                            Text(text = "💙 ", fontSize = 12.sp)
                          }
                          Text(
                            text = if (mpConnected) "DESCONECTAR CONTA" else "CONECTAR MINHA CONTA MERCADO PAGO",
                            style = MaterialTheme.typography.labelMedium.copy(
                              fontWeight = FontWeight.Bold,
                              letterSpacing = 0.5.sp,
                              fontSize = 11.sp
                            )
                          )
                        }
                      }
                    }
                  }
                }

                Spacer(modifier = Modifier.height(12.dp))
                
                // Informatia footer note
                Text(
                  text = "Taxa da plataforma: R$ 0,80 retidos por transação de forma automatizada via Split de Pagamento",
                  style = MaterialTheme.typography.bodySmall.copy(
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f),
                    fontSize = 10.sp
                  ),
                  textAlign = TextAlign.Center,
                  modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp)
                )
              }
            }
          }

          // SAVE ALL BUTTON
          item {
            Spacer(modifier = Modifier.height(20.dp))
            Button(
              onClick = {
                successMessage = "✨ Configurações do lojista salvas com sucesso!"
              },
              modifier = Modifier
                .fillMaxWidth()
                .height(54.dp)
                .testTag("save_config_button"),
              colors = ButtonDefaults.buttonColors(
                containerColor = MaterialTheme.colorScheme.primary,
                contentColor = MaterialTheme.colorScheme.onPrimary
              ),
              shape = RoundedCornerShape(27.dp)
            ) {
              Text(
                text = "SALVAR CONFIGURAÇÕES",
                style = MaterialTheme.typography.labelLarge.copy(
                  fontWeight = FontWeight.Bold,
                  letterSpacing = 1.sp
                )
              )
            }
          }
        }
        "Financas" -> {
          item {
            Text(
              text = "Extrato de Ganhos Lojista",
              style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
              modifier = Modifier.padding(bottom = 12.dp)
            )
          }

          // Card de Saldo
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
            ) {
              Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
              ) {
                Text(
                  text = "SALDO A RECEBER",
                  style = MaterialTheme.typography.labelSmall.copy(
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                  )
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                  text = "R$ ${String.format("%.2f", lojistaBalance)}",
                  style = MaterialTheme.typography.displayMedium.copy(
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Black,
                    fontSize = 32.sp
                  )
                )
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                  verticalAlignment = Alignment.CenterVertically
                ) {
                  Box(
                    modifier = Modifier
                      .size(8.dp)
                      .background(Color(0xFF2E7D32), CircleShape)
                  )
                  Spacer(modifier = Modifier.width(6.dp))
                  Text(
                    text = "Cidade: ${if (selectedCityType == TipoCidade.CAPITAL) "Capital (Logística R$ 3,00)" else "Interior (Logística R$ 2,00)"}",
                    style = MaterialTheme.typography.bodySmall.copy(
                      color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                    )
                  )
                }
              }
            }
            Spacer(modifier = Modifier.height(16.dp))
          }

          // Título de Vendas Recentes
          item {
            Row(
              verticalAlignment = Alignment.CenterVertically,
              modifier = Modifier.padding(bottom = 16.dp)
            ) {
              Text(text = "📊", fontSize = 16.sp, modifier = Modifier.padding(end = 8.dp))
              Text(
                text = "VENDAS RECENTES (SPLIT FINANCEIRO)",
                style = MaterialTheme.typography.labelSmall.copy(
                  color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f),
                  fontWeight = FontWeight.Bold,
                  letterSpacing = 0.5.sp
                )
              )
            }
          }

          if (lojistaSales.isEmpty()) {
            item {
              Box(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(vertical = 40.dp),
                contentAlignment = Alignment.Center
              ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                  Text(text = "🍳", fontSize = 36.sp)
                  Spacer(modifier = Modifier.height(12.dp))
                  Text(
                    text = "Nenhuma venda recente ainda.",
                    style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                  )
                }
              }
            }
          } else {
            items(lojistaSales) { sale ->
              val orderTotal = sale.orderValue
              val isCapital = sale.cityType == TipoCidade.CAPITAL
              val logisticDeduction = if (isCapital) 3.00 else 2.00
              val platformSaaS = 0.80
              val netValue = orderTotal - logisticDeduction - platformSaaS

              Card(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(vertical = 6.dp),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.1f))
              ) {
                Column(modifier = Modifier.padding(18.dp)) {
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                  ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                      Text(text = "🧾", fontSize = 14.sp, modifier = Modifier.padding(end = 6.dp))
                      Text(
                        text = "Pedido #${sale.orderId}",
                        style = MaterialTheme.typography.bodyMedium.copy(
                          fontWeight = FontWeight.Bold,
                          color = MaterialTheme.colorScheme.onSurface
                        )
                      )
                    }
                    Text(
                      text = "Split Realizado",
                      style = MaterialTheme.typography.labelSmall.copy(
                        color = Color(0xFF4CAF50),
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold
                      )
                    )
                  }
                  Spacer(modifier = Modifier.height(14.dp))
                  
                  // Detail rows
                  Row(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                  ) {
                    Text(text = "Valor Bruto do Pedido", style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)))
                    Text(text = "+R$ ${String.format("%.2f", orderTotal)}", style = MaterialTheme.typography.bodySmall.copy(color = Color(0xFF81C784), fontWeight = FontWeight.Bold))
                  }
                  Row(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                  ) {
                    Text(text = "Taxa Uni eats (SaaS)", style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)))
                    Text(text = "-R$ ${String.format("%.2f", platformSaaS)}", style = MaterialTheme.typography.bodySmall.copy(color = Color(0xFFEF5350)))
                  }
                  Row(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                  ) {
                    Text(text = "Logística Dividida (${if (isCapital) "Capital" else "Interior"})", style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)))
                    Text(text = "-R$ ${String.format("%.2f", logisticDeduction)}", style = MaterialTheme.typography.bodySmall.copy(color = Color(0xFFEF5350)))
                  }
                  
                  Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(MaterialTheme.colorScheme.outline.copy(alpha = 0.1f)).padding(vertical = 8.dp))
                  Spacer(modifier = Modifier.height(8.dp))
                  
                  Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                  ) {
                    Text(text = "VALOR LÍQUIDO", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onSurface))
                    Text(text = "R$ ${String.format("%.2f", netValue)}", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Black, color = MaterialTheme.colorScheme.primary))
                  }
                }
              }
            }
          }
        }
      }

      } else if (activeChefRole == "Motoboy") {
        // ====================================================================
        // MÓDULO DO MOTOBOY (Painel de Entregas)
        // ====================================================================

        item {
          Row(
            modifier = Modifier
              .fillMaxWidth()
              .background(MaterialTheme.colorScheme.surface, RoundedCornerShape(14.dp))
              .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f), RoundedCornerShape(14.dp))
              .padding(4.dp),
            horizontalArrangement = Arrangement.SpaceBetween
          ) {
            listOf(
              "Entregas" to "Painel de Entregas",
              "Carteira" to "Minha Carteira"
            ).forEach { (key, label) ->
              val isSelected = activeMotoboySubTab == key
              Box(
                modifier = Modifier
                  .weight(1f)
                  .clip(RoundedCornerShape(10.dp))
                  .background(if (isSelected) MaterialTheme.colorScheme.primary else Color.Transparent)
                  .clickable { activeMotoboySubTab = key }
                  .padding(vertical = 10.dp),
                contentAlignment = Alignment.Center
              ) {
                Text(
                  text = label,
                  style = MaterialTheme.typography.labelMedium.copy(
                    color = if (isSelected) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                    fontSize = 11.sp
                  )
                )
              }
            }
          }
          Spacer(modifier = Modifier.height(16.dp))
        }

        if (activeMotoboySubTab == "Entregas") {

        // 1. HEADER STATUS DO ENTREGADOR
        item {
          Card(
            modifier = Modifier
              .fillMaxWidth()
              .padding(vertical = 8.dp),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
          ) {
            Row(
              modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
              horizontalArrangement = Arrangement.SpaceBetween,
              verticalAlignment = Alignment.CenterVertically
            ) {
              Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                  modifier = Modifier
                    .size(8.dp)
                    .background(if (deliveryState == "idle") Color(0xFF2E7D32) else MaterialTheme.colorScheme.primary, CircleShape)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                  text = if (deliveryState == "idle") "Disponível para entregas"
                         else if (deliveryState == "offered") "Analisando proposta"
                         else "Em rota ativa (Passo $journeyStep/3)",
                  style = MaterialTheme.typography.bodyMedium.copy(
                    color = MaterialTheme.colorScheme.onSurface,
                    fontWeight = FontWeight.Bold
                  )
                )
              }
              Text(
                text = "ONLINE",
                style = MaterialTheme.typography.labelSmall.copy(
                  color = Color(0xFF2E7D32),
                  fontWeight = FontWeight.Bold,
                  letterSpacing = 1.sp
                )
              )
            }
          }
        }

        // 2. BUSCANDO CORRIDAS / PROCURANDO ESTADO
        if (deliveryState == "idle") {
          item {
            Column(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 40.dp),
              horizontalAlignment = Alignment.CenterHorizontally,
              verticalArrangement = Arrangement.Center
            ) {
              CircularProgressIndicator(
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.size(48.dp),
                strokeWidth = 2.dp
              )
              Spacer(modifier = Modifier.height(24.dp))
              Text(
                text = "Rastreando pedidos pendentes...",
                style = MaterialTheme.typography.titleMedium.copy(
                  color = MaterialTheme.colorScheme.onBackground,
                  fontWeight = FontWeight.Bold
                )
              )
              Spacer(modifier = Modifier.height(8.dp))
              Text(
                text = "Sua geolocalização está ativa na rede de logística Uni eats.",
                textAlign = TextAlign.Center,
                style = MaterialTheme.typography.bodySmall.copy(
                  color = MaterialTheme.colorScheme.onBackground.copy(alpha = 0.6f)
                )
              )
            }
          }
        }

        // 3. CORRIDA DISPONÍVEL (Card Flutuante Premium)
        if (deliveryState == "offered") {
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 12.dp)
                .testTag("offered_delivery_card"),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.5.dp, MaterialTheme.colorScheme.primary)
            ) {
              Column(modifier = Modifier.padding(24.dp)) {
                Row(
                  modifier = Modifier.fillMaxWidth(),
                  horizontalArrangement = Arrangement.SpaceBetween,
                  verticalAlignment = Alignment.CenterVertically
                ) {
                  Box(
                    modifier = Modifier
                      .clip(RoundedCornerShape(6.dp))
                      .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
                      .padding(horizontal = 10.dp, vertical = 4.dp)
                  ) {
                    Text(
                      text = "NOVA CORRIDA DISPONÍVEL",
                      style = MaterialTheme.typography.labelSmall.copy(
                        color = MaterialTheme.colorScheme.primary,
                        fontWeight = FontWeight.Black,
                        fontSize = 9.sp,
                        letterSpacing = 1.sp
                      )
                    )
                  }
                  Text(
                    text = "3.2 km",
                    style = MaterialTheme.typography.titleMedium.copy(
                      color = MaterialTheme.colorScheme.primary,
                      fontWeight = FontWeight.Bold
                    )
                  )
                }

                 val ratePerAddress = CalculadoraLogisticaService.calcularTaxaPorEndereco(selectedCityType)
                val totalEarnings = ratePerAddress * 3
                Spacer(modifier = Modifier.height(20.dp))
                Text(
                  text = "R$ ${String.format("%.2f", totalEarnings)}",
                  style = MaterialTheme.typography.displayMedium.copy(
                    color = MaterialTheme.colorScheme.onSurface,
                    fontWeight = FontWeight.Black,
                    letterSpacing = (-0.5).sp,
                    fontSize = 32.sp
                  ),
                  modifier = Modifier.align(Alignment.CenterHorizontally)
                )
                Text(
                  text = "Ganho Total: 3 destinos x R$ ${String.format("%.2f", ratePerAddress)}",
                  style = MaterialTheme.typography.bodySmall.copy(
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold
                  ),
                  modifier = Modifier.align(Alignment.CenterHorizontally)
                )

                Spacer(modifier = Modifier.height(24.dp))
                Spacer(modifier = Modifier.height(16.dp))

                // Rest details
                Row(
                  verticalAlignment = Alignment.CenterVertically,
                  modifier = Modifier.padding(vertical = 4.dp)
                ) {
                  Text(text = "🏰", fontSize = 16.sp, modifier = Modifier.padding(end = 12.dp))
                  Column {
                    Text(
                      text = "Retirar em:",
                      style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                    )
                    Text(text = "UniEats Signature", style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold))
                  }
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Client destination details
                Row(
                  verticalAlignment = Alignment.CenterVertically,
                  modifier = Modifier.padding(vertical = 4.dp)
                ) {
                  Text(text = "🛵", fontSize = 16.sp, modifier = Modifier.padding(end = 12.dp))
                  Column {
                    Text(
                      text = "Entregar em:",
                      style = MaterialTheme.typography.labelSmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                    )
                    Text(text = "Al. Gabriel Monteiro da Silva, 1420 - Jd. América", style = MaterialTheme.typography.bodyMedium)
                  }
                }

                Spacer(modifier = Modifier.height(28.dp))

                Row(
                  modifier = Modifier.fillMaxWidth(),
                  horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                  OutlinedButton(
                    modifier = Modifier
                      .weight(1f)
                      .height(48.dp)
                      .testTag("reject_delivery_button"),
                    onClick = {
                      deliveryState = "idle"
                      successMessage = "Corrida Recusada. Buscando novas rotas..."
                    },
                    border = BorderStroke(1.dp, Color(0xFFEF5350).copy(alpha = 0.6f)),
                    colors = ButtonDefaults.outlinedButtonColors(contentColor = Color(0xFFEF5350)),
                    shape = RoundedCornerShape(24.dp)
                  ) {
                    Text("RECUSAR", style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold, letterSpacing = 1.sp, fontSize = 11.sp))
                  }

                  Button(
                    modifier = Modifier
                      .weight(1f)
                      .height(48.dp)
                      .testTag("accept_delivery_button"),
                    onClick = {
                      deliveryState = "accepted"
                      journeyStep = 1
                      simulationProgress = 0.0f
                      successMessage = "Corrida Aceita! Dirija-se ao restaurante."
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary),
                    shape = RoundedCornerShape(24.dp)
                  ) {
                    Text("ACEITAR", style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold, letterSpacing = 1.sp, fontSize = 11.sp, color = Color.Black))
                  }
                }
              }
            }
          }
        }

        // 4. MAPA RASTREAMENTO GPS ATIVO
        if (deliveryState == "accepted") {
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .height(300.dp)
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = Color(0xFF1E1E1E)),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
            ) {
              Box(modifier = Modifier.fillMaxSize()) {
                // Background street lines (Custom Canvas fallback representation)
                Column(
                  modifier = Modifier.fillMaxSize(),
                  verticalArrangement = Arrangement.SpaceBetween
                ) {
                  repeat(6) {
                    Box(
                      modifier = Modifier
                        .fillMaxWidth()
                        .height(1.dp)
                        .background(Color.White.copy(alpha = 0.03f))
                    )
                  }
                }
                Row(
                  modifier = Modifier.fillMaxSize(),
                  horizontalArrangement = Arrangement.SpaceBetween
                ) {
                  repeat(6) {
                    Box(
                      modifier = Modifier
                        .fillMaxHeight()
                        .width(1.dp)
                        .background(Color.White.copy(alpha = 0.03f))
                    )
                  }
                }

                // GPS live directions
                Box(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp)
                    .background(Color.Black.copy(alpha = 0.85f), RoundedCornerShape(10.dp))
                    .border(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                    .padding(horizontal = 14.dp, vertical = 10.dp)
                ) {
                  Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(text = "🧭", fontSize = 16.sp, modifier = Modifier.padding(end = 10.dp))
                    Text(
                      text = if (journeyStep == 1) "Dirija-se ao restaurante para a retirada"
                             else if (journeyStep == 2) "Aguardando liberação gourmet do Chef"
                             else "A caminho da residência do cliente",
                      style = MaterialTheme.typography.bodySmall.copy(
                        color = Color.White,
                        fontWeight = FontWeight.Bold
                      )
                    )
                  }
                }

                // Map markers
                // RESTAURANT MARKER
                Box(
                  modifier = Modifier
                    .offset(x = 60.dp, y = 140.dp),
                  contentAlignment = Alignment.Center
                ) {
                  Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                      modifier = Modifier
                        .background(MaterialTheme.colorScheme.primary, RoundedCornerShape(4.dp))
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                      Text("RESTAURANTE", fontSize = 8.sp, fontWeight = FontWeight.Bold, color = Color.Black)
                    }
                    Text("🏰", fontSize = 24.sp)
                  }
                }

                // CLIENT MARKER
                Box(
                  modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .offset(x = (-30).dp, y = (-60).dp),
                  contentAlignment = Alignment.Center
                ) {
                  Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                      modifier = Modifier
                        .background(Color(0xFF2E7D32), RoundedCornerShape(4.dp))
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                      Text("CLIENTE", fontSize = 8.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    }
                    Text("🏠", fontSize = 24.sp)
                  }
                }

                // RIDER MOTOBOY LIVE DOT
                val riderX = 60.dp + (160.dp * simulationProgress)
                val riderY = 160.dp - (50.dp * simulationProgress)

                Box(
                  modifier = Modifier
                    .offset(x = riderX, y = riderY)
                    .clip(CircleShape)
                    .background(Color.Black)
                    .border(1.dp, MaterialTheme.colorScheme.primary, CircleShape)
                    .padding(6.dp)
                ) {
                  Text("🏍️", fontSize = 20.sp)
                }

                // Live Geo Telemetry
                Box(
                  modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(16.dp)
                    .background(Color.Black.copy(alpha = 0.9f), RoundedCornerShape(8.dp))
                    .padding(8.dp)
                ) {
                  Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    Text(
                      text = "Lat: ${String.format("%.5f", riderLatitude)}",
                      style = MaterialTheme.typography.bodySmall.copy(color = Color.LightGray, fontFamily = FontFamily.Monospace, fontSize = 9.sp)
                    )
                    Text(
                      text = "Lng: ${String.format("%.5f", riderLongitude)}",
                      style = MaterialTheme.typography.bodySmall.copy(color = Color.LightGray, fontFamily = FontFamily.Monospace, fontSize = 9.sp)
                    )
                  }
                }
              }
            }
          }

          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 12.dp),
              shape = RoundedCornerShape(12.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
            ) {
              Column(modifier = Modifier.padding(16.dp)) {
                Text(
                  text = "ETAPA DO ATENDIMENTO",
                  style = MaterialTheme.typography.labelSmall.copy(
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                  )
                )
                Spacer(modifier = Modifier.height(12.dp))

                Row(
                  modifier = Modifier.fillMaxWidth(),
                  horizontalArrangement = Arrangement.SpaceBetween
                ) {
                  listOf(
                    1 to "Retirada",
                    2 to "Preparo",
                    3 to "Rota Cliente"
                  ).forEach { (step, name) ->
                    val isActive = journeyStep >= step
                    Row(verticalAlignment = Alignment.CenterVertically) {
                      Text(
                        text = if (isActive) "✓" else "○",
                        color = if (isActive) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.3f),
                        fontWeight = FontWeight.Bold,
                        fontSize = 14.sp
                      )
                      Spacer(modifier = Modifier.width(6.dp))
                      Text(
                        text = name,
                        style = MaterialTheme.typography.bodySmall.copy(
                          color = if (isActive) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f),
                          fontWeight = if (isActive) FontWeight.Bold else FontWeight.Normal
                        )
                      )
                    }
                  }
                }

                Spacer(modifier = Modifier.height(20.dp))

                // Status Button
                Button(
                  modifier = Modifier
                    .fillMaxWidth()
                    .height(52.dp)
                    .testTag("update_delivery_status_button"),
                  onClick = {
                    if (journeyStep < 3) {
                      journeyStep++
                      simulationProgress = 0.0f
                      successMessage = when (journeyStep) {
                        2 -> "Retirada concluída. Prato sendo finalizado pelo Chef."
                        3 -> "Pedido coletado! Rota para o endereço do cliente iniciada."
                        else -> ""
                      }
                    } else {
                      val ratePerAddress = if (selectedCityType == TipoCidade.CAPITAL) 6.00 else 4.00
                      val routeEarnings = ratePerAddress * 3
                      onUpdateMotoboyBalance(motoboyBalance + routeEarnings)
                      motoboyRoutes.add(0, CompletedRouteKotlin(
                        name = "Rota Simulação #${(1000..9999).random()}",
                        addressesCount = 3,
                        earnings = routeEarnings,
                        status = "Pago 100%"
                      ))
                      journeyStep = 4
                      deliveryState = "idle"
                      successMessage = "✓ Pedido Entregue com Sucesso! R$ ${String.format("%.2f", routeEarnings)} adicionados."
                    }
                  },
                  colors = ButtonDefaults.buttonColors(
                    containerColor = if (journeyStep == 3) Color(0xFF2E7D32) else MaterialTheme.colorScheme.primary,
                    contentColor = if (journeyStep == 3) Color.White else Color.Black
                  ),
                  shape = RoundedCornerShape(26.dp)
                ) {
                  Text(
                    text = if (journeyStep == 1) "CHEGUEI NO RESTAURANTE"
                           else if (journeyStep == 2) "PEDIDO COLETADO"
                           else "PEDIDO ENTREGUE",
                    style = MaterialTheme.typography.labelLarge.copy(
                      fontWeight = FontWeight.Black,
                      letterSpacing = 1.sp,
                      fontSize = 12.sp
                    )
                  )
                }
              }
            }
          }
        }

        } else {
          // CARTEIRA DO MOTOBOY
          item {
            Text(
              text = "Carteira & Repasses",
              style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
              modifier = Modifier.padding(bottom = 12.dp)
            )
          }

          // Card de Saldo do Motoboy
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
            ) {
              Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
              ) {
                Text(
                  text = "SALDO DISPONÍVEL",
                  style = MaterialTheme.typography.labelSmall.copy(
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                  )
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                  text = "R$ ${String.format("%.2f", motoboyBalance)}",
                  style = MaterialTheme.typography.displayMedium.copy(
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.Black,
                    fontSize = 32.sp
                  )
                )
                Spacer(modifier = Modifier.height(16.dp))
                
                // Pix Cashout Button with loading simulator
                val scope = rememberCoroutineScope()
                Button(
                  onClick = {
                    if (motoboyBalance > 0 && !isWithdrawingMotoboy) {
                      isWithdrawingMotoboy = true
                      scope.launch {
                        delay(2000)
                        isWithdrawingMotoboy = false
                        onUpdateMotoboyBalance(0.0)
                        successMessage = "✓ Transferência Pix de R$ ${String.format("%.2f", motoboyBalance)} realizada para sua conta cadastrada!"
                      }
                    }
                  },
                  modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                  shape = RoundedCornerShape(24.dp),
                  colors = ButtonDefaults.buttonColors(
                    containerColor = if (motoboyBalance > 0) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.1f),
                    contentColor = if (motoboyBalance > 0) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
                  ),
                  enabled = motoboyBalance > 0 && !isWithdrawingMotoboy
                ) {
                  if (isWithdrawingMotoboy) {
                    CircularProgressIndicator(
                      color = MaterialTheme.colorScheme.onPrimary,
                      modifier = Modifier.size(20.dp),
                      strokeWidth = 2.dp
                    )
                  } else {
                    Text(
                      text = "SOLICITAR SAQUE VIA PIX",
                      style = MaterialTheme.typography.labelMedium.copy(
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                      )
                    )
                  }
                }
              }
            }
            Spacer(modifier = Modifier.height(16.dp))
          }

          // Histórico de Corridas Concluídas
          item {
            Row(
              verticalAlignment = Alignment.CenterVertically,
              modifier = Modifier.padding(bottom = 16.dp)
            ) {
              Text(text = "🏍️", fontSize = 16.sp, modifier = Modifier.padding(end = 8.dp))
              Text(
                text = "CORRIDAS CONCLUÍDAS (LOGÍSTICA)",
                style = MaterialTheme.typography.labelSmall.copy(
                  color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.8f),
                  fontWeight = FontWeight.Bold,
                  letterSpacing = 0.5.sp
                )
              )
            }
          }

          if (motoboyRoutes.isEmpty()) {
            item {
              Box(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(vertical = 40.dp),
                contentAlignment = Alignment.Center
              ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                  Text(text = "🛣️", fontSize = 36.sp)
                  Spacer(modifier = Modifier.height(12.dp))
                  Text(
                    text = "Nenhuma corrida registrada ainda.",
                    style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                  )
                }
              }
            }
          } else {
            items(motoboyRoutes) { route ->
              Card(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(vertical = 6.dp),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
                border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline.copy(alpha = 0.1f))
              ) {
                Row(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(18.dp),
                  horizontalArrangement = Arrangement.SpaceBetween,
                  verticalAlignment = Alignment.CenterVertically
                ) {
                  Column {
                    Text(
                      text = route.name,
                      style = MaterialTheme.typography.bodyMedium.copy(
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                      )
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                      text = "${route.addressesCount} endereços • Taxa dividida",
                      style = MaterialTheme.typography.bodySmall.copy(
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                      )
                    )
                  }
                  Column(horizontalAlignment = Alignment.End) {
                    Text(
                      text = "+R$ ${String.format("%.2f", route.earnings)}",
                      style = MaterialTheme.typography.bodyMedium.copy(
                        fontWeight = FontWeight.Black,
                        color = MaterialTheme.colorScheme.primary
                      )
                    )
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                      text = route.status,
                      style = MaterialTheme.typography.labelSmall.copy(
                        color = Color(0xFF4CAF50),
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold
                      )
                    )
                  }
                }
              }
            }
          }
        }
      } else if (activeChefRole == "Admin") {
        // ====================================================================
        // MÓDULO SUPER ADMIN (Painel do Dono)
        // ====================================================================

        if (!isUserVerifiedOwner) {
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 16.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
            ) {
              Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
              ) {
                Text(text = "🔒", fontSize = 48.sp)
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                  text = "Acesso Altamente Restrito",
                  style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold)
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                  text = "Esta área contém configurações do sistema, taxas de split de pagamento e gerenciamento de faturamento.",
                  style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)),
                  textAlign = TextAlign.Center
                )
                Spacer(modifier = Modifier.height(24.dp))

                // SECURITY VALIDATION BLOCK (SIMULATION)
                // ------------------------------------------------------------------
                // TRAVA DE SEGURANÇA: Verificação em nível de produção (Ex: API token / isSuperAdmin check)
                // if (usuario.isSuperAdmin) { isUserVerifiedOwner = true }
                // ------------------------------------------------------------------
                Button(
                  modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .testTag("admin_unlock_button"),
                  onClick = {
                    isUserVerifiedOwner = true
                    successMessage = "🛡️ Acesso super-administrador liberado com sucesso!"
                  },
                  colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary),
                  shape = RoundedCornerShape(24.dp)
                ) {
                  Text("AUTENTICAR COMO PROPRIETÁRIO", style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.Bold, color = Color.Black, fontSize = 11.sp))
                }
              }
            }
          }
        } else {
          // OWNER IDENTITY
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(12.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.05f)),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.15f))
            ) {
              Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
              ) {
                Text(text = "🛡️", fontSize = 24.sp, modifier = Modifier.padding(end = 12.dp))
                Column {
                  Text(
                    text = "GUILHERME PRADO (PROPRIETÁRIO)",
                    style = MaterialTheme.typography.labelSmall.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                  )
                  Text(
                    text = "aquilaa043@gmail.com",
                    style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                  )
                }
              }
            }
          }

          // GRATUITY SWITCH (Modo Plataforma Gratuita)
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
            ) {
              Row(
                modifier = Modifier
                  .fillMaxWidth()
                  .padding(20.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
              ) {
                Column(modifier = Modifier.weight(1f)) {
                  Text(
                    text = "Modo Plataforma Gratuita",
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold)
                  )
                  Spacer(modifier = Modifier.height(4.dp))
                  Text(
                    text = "Se ativo, lojistas ficam isentos de assinaturas Bronze, Prata e Ouro.",
                    style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                  )
                }
                Switch(
                  checked = modoGratuitoSemAssinatura,
                  onCheckedChange = { modoGratuitoSemAssinatura = it },
                  colors = SwitchDefaults.colors(
                    checkedThumbColor = MaterialTheme.colorScheme.primary,
                    checkedTrackColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.3f)
                  ),
                  modifier = Modifier.testTag("admin_free_mode_switch")
                )
              }
            }
          }

          // CONFIGURAÇÃO DE CIDADE E LOGÍSTICA (REGRA DE PORTE DA CIDADE)
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.12f))
            ) {
              Column(modifier = Modifier.padding(20.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Text(text = "🏙️", fontSize = 16.sp, modifier = Modifier.padding(end = 8.dp))
                  Text(
                    text = "Configuração de Cidade & Logística",
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                  )
                }
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                  text = "Altere o porte da cidade do estabelecimento para ajustar automaticamente as taxas de split e o ganho dos motoboys em tempo real.",
                  style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                )
                Spacer(modifier = Modifier.height(16.dp))

                Row(
                  modifier = Modifier.fillMaxWidth(),
                  horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                  // Interior Button
                  val isInterior = selectedCityType == TipoCidade.INTERIOR
                  Card(
                    modifier = Modifier
                      .weight(1f)
                      .clickable { onCityTypeChange(TipoCidade.INTERIOR) },
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(
                      width = if (isInterior) 2.dp else 1.dp,
                      color = if (isInterior) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)
                    ),
                    colors = CardDefaults.cardColors(
                      containerColor = if (isInterior) MaterialTheme.colorScheme.primary.copy(alpha = 0.05f) else MaterialTheme.colorScheme.surface
                    )
                  ) {
                    Column(
                      modifier = Modifier.padding(12.dp),
                      horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                      Text(text = "🌳", fontSize = 20.sp)
                      Spacer(modifier = Modifier.height(4.dp))
                      Text(
                        text = "Interior",
                        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                      )
                      Text(
                        text = "Split R$ 4,00\n(R$ 2 cliente / R$ 2 loja)",
                        style = MaterialTheme.typography.labelSmall.copy(
                          color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                          fontSize = 8.sp,
                          textAlign = TextAlign.Center
                        )
                      )
                    }
                  }

                  // Capital Button
                  val isCapital = selectedCityType == TipoCidade.CAPITAL
                  Card(
                    modifier = Modifier
                      .weight(1f)
                      .clickable { onCityTypeChange(TipoCidade.CAPITAL) },
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(
                      width = if (isCapital) 2.dp else 1.dp,
                      color = if (isCapital) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outline.copy(alpha = 0.15f)
                    ),
                    colors = CardDefaults.cardColors(
                      containerColor = if (isCapital) MaterialTheme.colorScheme.primary.copy(alpha = 0.05f) else MaterialTheme.colorScheme.surface
                    )
                  ) {
                    Column(
                      modifier = Modifier.padding(12.dp),
                      horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                      Text(text = "🏢", fontSize = 20.sp)
                      Spacer(modifier = Modifier.height(4.dp))
                      Text(
                        text = "Capital",
                        style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                      )
                      Text(
                        text = "Split R$ 6,00\n(R$ 3 cliente / R$ 3 loja)",
                        style = MaterialTheme.typography.labelSmall.copy(
                          color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f),
                          fontSize = 8.sp,
                          textAlign = TextAlign.Center
                        )
                      )
                    }
                  }
                }
              }
            }
          }

          // CONFIGURADOR DE PLANOS FUTUROS
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.08f))
            ) {
              Column(modifier = Modifier.padding(20.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Text(text = "⭐", fontSize = 16.sp, modifier = Modifier.padding(end = 8.dp))
                  Text(
                    text = "Configurador de Planos Futuros",
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                  )
                }
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                  text = "Configure as mensalidades das assinaturas Bronze, Prata e Ouro que ficarão salvas no sistema.",
                  style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                )
                Spacer(modifier = Modifier.height(20.dp))

                // Price Bronze
                Row(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp),
                  verticalAlignment = Alignment.CenterVertically
                ) {
                  Text(
                    text = "Bronze Selection",
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold),
                    modifier = Modifier.weight(1.5f)
                  )
                  OutlinedTextField(
                    value = priceBronze,
                    onValueChange = { priceBronze = it },
                    prefix = { Text("R$ ", color = MaterialTheme.colorScheme.primary) },
                    modifier = Modifier
                      .weight(1f)
                      .height(54.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                      focusedBorderColor = MaterialTheme.colorScheme.primary,
                      unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)
                    ),
                    shape = RoundedCornerShape(8.dp),
                    singleLine = true
                  )
                }

                // Price Prata
                Row(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp),
                  verticalAlignment = Alignment.CenterVertically
                ) {
                  Text(
                    text = "Prata Premium",
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold),
                    modifier = Modifier.weight(1.5f)
                  )
                  OutlinedTextField(
                    value = pricePrata,
                    onValueChange = { pricePrata = it },
                    prefix = { Text("R$ ", color = MaterialTheme.colorScheme.primary) },
                    modifier = Modifier
                      .weight(1f)
                      .height(54.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                      focusedBorderColor = MaterialTheme.colorScheme.primary,
                      unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)
                    ),
                    shape = RoundedCornerShape(8.dp),
                    singleLine = true
                  )
                }

                // Price Ouro
                Row(
                  modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp),
                  verticalAlignment = Alignment.CenterVertically
                ) {
                  Text(
                    text = "L'Or Exclusive",
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold),
                    modifier = Modifier.weight(1.5f)
                  )
                  OutlinedTextField(
                    value = priceOuro,
                    onValueChange = { priceOuro = it },
                    prefix = { Text("R$ ", color = MaterialTheme.colorScheme.primary) },
                    modifier = Modifier
                      .weight(1f)
                      .height(54.dp),
                    colors = OutlinedTextFieldDefaults.colors(
                      focusedBorderColor = MaterialTheme.colorScheme.primary,
                      unfocusedBorderColor = MaterialTheme.colorScheme.outline.copy(alpha = 0.2f)
                    ),
                    shape = RoundedCornerShape(8.dp),
                    singleLine = true
                  )
                }

                Spacer(modifier = Modifier.height(20.dp))

                Button(
                  modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
                    .testTag("save_plans_button"),
                  onClick = {
                    successMessage = "✓ Valores dos planos configurados com sucesso!"
                  },
                  colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary),
                  shape = RoundedCornerShape(24.dp)
                ) {
                  Text("SALVAR CONFIGURAÇÃO DOS PLANOS", style = MaterialTheme.typography.labelMedium.copy(fontWeight = FontWeight.Bold, color = Color.Black, fontSize = 11.sp))
                }
              }
            }
          }

          // METRIC AUDIT SPLIT
          item {
            Card(
              modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
              shape = RoundedCornerShape(16.dp),
              colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primary.copy(alpha = 0.02f)),
              border = BorderStroke(1.dp, MaterialTheme.colorScheme.primary.copy(alpha = 0.12f))
            ) {
              Column(modifier = Modifier.padding(20.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                  Text(text = "📈", fontSize = 16.sp, modifier = Modifier.padding(end = 8.dp))
                  Text(
                    text = "Auditoria de Split (Transparente)",
                    style = MaterialTheme.typography.titleSmall.copy(fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                  )
                }
                Spacer(modifier = Modifier.height(12.dp))

                Row(
                  modifier = Modifier.fillMaxWidth(),
                  horizontalArrangement = Arrangement.SpaceBetween
                ) {
                  Text(
                    text = "Taxas retidas (R$ 0,80 por pedido):",
                    style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                  )
                  Text(
                    text = "R$ 1.240,80",
                    style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                  )
                }
                Spacer(modifier = Modifier.height(6.dp))

                Row(
                  modifier = Modifier.fillMaxWidth(),
                  horizontalArrangement = Arrangement.SpaceBetween
                ) {
                  Text(
                    text = "Total de transações processadas:",
                    style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                  )
                  Text(
                    text = "1.551 pedidos",
                    style = MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.Bold)
                  )
                }
              }
            }
          }
        }
      }
    }

    // 3. UPSCALE THERMAL COMANDA (RECEIPT) OVERLAY MODAL
    AnimatedVisibility(
      visible = selectedOrderForComanda != null,
      enter = fadeIn() + slideInVertically(initialOffsetY = { h -> h / 3 }),
      exit = fadeOut() + slideOutVertically(targetOffsetY = { h -> h / 3 })
    ) {
      selectedOrderForComanda?.let { order ->
        Box(
          modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.85f))
            .clickable { selectedOrderForComanda = null } // Click outside to close
            .padding(horizontal = 24.dp, vertical = 40.dp),
          contentAlignment = Alignment.Center
        ) {
          // Thermal Receipt Container
          Card(
            modifier = Modifier
              .fillMaxWidth()
              .widthIn(max = 420.dp)
              .clickable(enabled = false) {}, // Prevent closing when clicking receipt
            shape = RoundedCornerShape(4.dp), // Sharper, premium ticket corners
            colors = CardDefaults.cardColors(containerColor = Color(0xFFFBFBF9)), // Fine raw cream paper texture
            elevation = CardDefaults.cardElevation(defaultElevation = 16.dp)
          ) {
            Column(
              modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp)
                .verticalScroll(rememberScrollState()),
              horizontalAlignment = Alignment.CenterHorizontally
            ) {
              // Receipt Tear Line Graphic
              Text(
                text = "------------------------------------------",
                style = MaterialTheme.typography.bodySmall.copy(
                  fontFamily = FontFamily.Monospace,
                  color = Color.Black.copy(alpha = 0.25f)
                ),
                maxLines = 1
              )

              Spacer(modifier = Modifier.height(12.dp))

              // High Gastronomy Branding Header
              Text(
                text = "UNI EATS GOURMET",
                style = MaterialTheme.typography.titleMedium.copy(
                  fontFamily = FontFamily.Monospace,
                  fontWeight = FontWeight.Bold,
                  color = Color.Black,
                  letterSpacing = 2.sp
                )
              )
              
              Text(
                text = "Sabor elitizado sob demanda",
                style = MaterialTheme.typography.labelSmall.copy(
                  fontFamily = FontFamily.Monospace,
                  color = Color.Black.copy(alpha = 0.6f),
                  fontSize = 9.sp
                )
              )

              Spacer(modifier = Modifier.height(16.dp))
              Text(
                text = "=== COMANDA DE COZINHA ===",
                style = MaterialTheme.typography.labelMedium.copy(
                  fontFamily = FontFamily.Monospace,
                  fontWeight = FontWeight.Bold,
                  color = Color.Black
                )
              )

              Spacer(modifier = Modifier.height(12.dp))

              // Order ID & Status
              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
              ) {
                Text(
                  text = "PEDIDO: ${order.id}",
                  style = MaterialTheme.typography.bodyMedium.copy(
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black
                  )
                )
                Text(
                  text = "STATUS: ${order.status.name}",
                  style = MaterialTheme.typography.bodyMedium.copy(
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black
                  )
                )
              }

              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
              ) {
                Text(
                  text = "HRA: ${order.orderTime}",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Black
                  )
                )
                Text(
                  text = "DATA: 06/07/2026",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Black
                  )
                )
              }

              Spacer(modifier = Modifier.height(12.dp))
              Text(
                text = "------------------------------------------",
                style = MaterialTheme.typography.bodySmall.copy(
                  fontFamily = FontFamily.Monospace,
                  color = Color.Black.copy(alpha = 0.25f)
                ),
                maxLines = 1
              )

              // Customer info in receipt
              Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.Start
              ) {
                Text(
                  text = "CLIENTE: ${order.customerName}",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black
                  )
                )
                Text(
                  text = "TEL: ${order.customerPhone}",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Black
                  )
                )
                Text(
                  text = "ENTREGA: ${order.customerAddress}",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Black
                  )
                )
                Text(
                  text = "ROTA: ${order.deliveryType.uppercase()}",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black
                  )
                )
              }

              Spacer(modifier = Modifier.height(12.dp))
              Text(
                text = "------------------------------------------",
                style = MaterialTheme.typography.bodySmall.copy(
                  fontFamily = FontFamily.Monospace,
                  color = Color.Black.copy(alpha = 0.25f)
                ),
                maxLines = 1
              )

              // Items Grid
              Column(modifier = Modifier.fillMaxWidth()) {
                order.items.forEach { item ->
                  Row(
                    modifier = Modifier
                      .fillMaxWidth()
                      .padding(vertical = 4.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                  ) {
                    Text(
                      text = "${item.quantity}x ${item.name}",
                      style = MaterialTheme.typography.bodySmall.copy(
                        fontFamily = FontFamily.Monospace,
                        fontWeight = FontWeight.Bold,
                        color = Color.Black
                      ),
                      modifier = Modifier.weight(1f)
                    )
                    Text(
                      text = item.price,
                      style = MaterialTheme.typography.bodySmall.copy(
                        fontFamily = FontFamily.Monospace,
                        color = Color.Black
                      )
                    )
                  }
                }
              }

              if (order.notes.isNotBlank()) {
                Spacer(modifier = Modifier.height(10.dp))
                Text(
                  text = "* OBS: ${order.notes.uppercase()}",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Red.copy(alpha = 0.8f),
                    fontWeight = FontWeight.Bold
                  ),
                  modifier = Modifier.align(Alignment.Start)
                )
              }

              Spacer(modifier = Modifier.height(14.dp))
              Text(
                text = "------------------------------------------",
                style = MaterialTheme.typography.bodySmall.copy(
                  fontFamily = FontFamily.Monospace,
                  color = Color.Black.copy(alpha = 0.25f)
                ),
                maxLines = 1
              )

              // Totals
              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
              ) {
                Text(
                  text = "SUBTOTAL",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Black
                  )
                )
                Text(
                  text = order.total,
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Black
                  )
                )
              }
              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
              ) {
                Text(
                  text = "TAXA DE CURADORIA",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Black
                  )
                )
                Text(
                  text = "R$ 0,00",
                  style = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = FontFamily.Monospace,
                    color = Color.Black
                  )
                )
              }
              Spacer(modifier = Modifier.height(6.dp))
              Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
              ) {
                Text(
                  text = "TOTAL GERAL",
                  style = MaterialTheme.typography.bodyMedium.copy(
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black,
                    fontSize = 16.sp
                  )
                )
                Text(
                  text = order.total,
                  style = MaterialTheme.typography.bodyMedium.copy(
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    color = Color.Black,
                    fontSize = 16.sp
                  )
                )
              }

              Spacer(modifier = Modifier.height(24.dp))

              // QR CODE PLACEHOLDER
              Box(
                modifier = Modifier
                  .size(90.dp)
                  .background(Color.White)
                  .border(2.dp, Color.Black)
                  .padding(8.dp),
                contentAlignment = Alignment.Center
              ) {
                // Pixelated QR simulation
                Column(verticalArrangement = Arrangement.spacedBy(2.dp)) {
                  repeat(10) { rowIndex ->
                    Row(horizontalArrangement = Arrangement.spacedBy(2.dp)) {
                      repeat(10) { colIndex ->
                        val isBlack = (rowIndex + colIndex) % 3 == 0 || (rowIndex * colIndex) % 4 == 1 || (rowIndex < 3 && colIndex < 3) || (rowIndex > 6 && colIndex < 3) || (rowIndex < 3 && colIndex > 6)
                        Box(
                          modifier = Modifier
                            .size(6.dp)
                            .background(if (isBlack) Color.Black else Color.White)
                        )
                      }
                    }
                  }
                }
              }

              Spacer(modifier = Modifier.height(8.dp))
              Text(
                text = "COMANDA DIGITAL UNI EATS",
                style = MaterialTheme.typography.labelSmall.copy(
                  fontFamily = FontFamily.Monospace,
                  color = Color.Black.copy(alpha = 0.5f),
                  fontSize = 8.sp,
                  fontWeight = FontWeight.Bold
                )
              )
              Text(
                text = "Valide e fature pelo QR Code",
                style = MaterialTheme.typography.labelSmall.copy(
                  fontFamily = FontFamily.Monospace,
                  color = Color.Black.copy(alpha = 0.4f),
                  fontSize = 7.sp
                )
              )

              Spacer(modifier = Modifier.height(16.dp))
              Text(
                text = "------------------------------------------",
                style = MaterialTheme.typography.bodySmall.copy(
                  fontFamily = FontFamily.Monospace,
                  color = Color.Black.copy(alpha = 0.25f)
                ),
                maxLines = 1
              )

              Spacer(modifier = Modifier.height(16.dp))

              // Close bottom thermal ticket button
              Button(
                onClick = { selectedOrderForComanda = null },
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(
                  containerColor = Color.Black,
                  contentColor = Color.White
                ),
                modifier = Modifier
                  .fillMaxWidth()
                  .height(48.dp)
              ) {
                Text(
                  text = "FECHAR PREVIEW COMANDA",
                  style = MaterialTheme.typography.labelSmall.copy(
                    fontFamily = FontFamily.Monospace,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.sp
                  )
                )
              }
            }
          }
        }
      }
    }
  }
}
