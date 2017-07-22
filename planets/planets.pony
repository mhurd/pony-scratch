use "time"
use collections = "collections"

actor Planet
  let _name: String
  let _earthYearMultiplier: F32
  var _year: F32 = 0

  new create(name': String, earthYearMultiplier': F32) =>
    _name = name'
    _earthYearMultiplier = earthYearMultiplier'

  fun year(): F32 => _year
  fun earthYearMultiplier(): F32 => _earthYearMultiplier  
  fun calOneEarthYear(): F32 => year() + earthYearMultiplier()
  // needs to be a ref function as it modified a variable
  fun ref rotateOneEarthYear(): F32 =>
    _year = calOneEarthYear()
    year()
  fun name(): String => _name

  be printDetails(env: Env) => 
    env.out.print(name() + ", Earth years = " + year().string())

  be rotateEarthYears(env: Env, years: USize) =>
    for i in collections.Range(0, years) do 
      rotateOneEarthYear()
      env.out.print("An Earth year passes, " + year().string() 
        + " " + name() + " years have now passed.")
    end

class EarthGoesRoundTheSunTimer is TimerNotify

  let _env: Env
  var _earthYear: U64
  let _planets: Array[Planet]

  new iso create(env: Env, planets: Array[Planet] iso) =>
    _env = env
    _earthYear = 0
    _planets = consume planets

  fun ref _nextEarthYear(): String =>
    _earthYear = _earthYear + 1
    _earthYear.string()

  fun ref apply(timer: Timer, count: U64): Bool =>
    _env.out.print("... Earth Year " + _nextEarthYear())
    for planet in _planets.values() do
      planet.rotateEarthYears(_env, 1)
    end
    true

actor Main 

  let _env: Env

  new create(env: Env) =>
    _env = env

    let mercury = Planet("Mercury", 4.14914)
    let venus = Planet("Venus", 1.62439)
    let earth = Planet("Earth", 1)
    let mars = Planet("Mars", 0.53131)
    let jupiter = Planet("Jupiter", 0.08424)
    let saturn = Planet("Saturn", 0.03394)
    let uranus = Planet("Uranus", 0.01189)
    let neptune = Planet("Neptune", 0.00606)
    let pluto = Planet("Pluto", 0.00403)

    let planets: Array[Planet] iso = 
      // we need to recover the Array ref to an iso
      recover 
        [mercury; venus; earth; mars; jupiter; saturn; uranus; neptune; pluto] 
      end

    let timers = Timers
    // needs to consume the planets reference as its an iso
    let timer = Timer(EarthGoesRoundTheSunTimer(_env, consume planets), 0, 3_000_000_000)

    // needs to consume the timer reference as its an iso
    timers(consume timer)