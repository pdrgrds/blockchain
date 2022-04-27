// SPDX-License-Identifier: MIT
pragma solidity >0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;
import "./ERC20.sol";

contract Disney {

    // ------------------------------------- DECLARACIONES INICIALES ------------------------------------- 

    //Instancia del contracto token
    ERC20Basic private token;

    //Direccion de Disney (owner)
    address payable public owner;

    //Constructor
    constructor () public {
        token = new ERC20Basic(10000);
        owner = msg.sender;
    }

    //Estructura de datos para almacenar a los clientes de Disney
    struct cliente {
        uint tokens_comprados;
        string [] atracciones_disfrutadas;
    }

    //Mapping para el registro de clientes
    mapping (address => cliente) public Clientes;

    // ------------------------------------- GESTION DE TOKENS ------------------------------------- 

    //Función para establecer el precio de un token
    function PrecioTokens(uint _numTokens) internal pure returns(uint){
        //Conversión de tokens a Ethers: 1 Token -> 1 Ether
        return _numTokens*(1 ether);
    }

    //Funcion para comprar Tokens en disney y disfrutar de las atracciones
    function CompraTokens(uint _numTokens) public payable {
        // Establecer el precio de los tokens
        uint coste = PrecioTokens(_numTokens);
        //Se evaluea el dinero que el cliente paga por los Tokens
        require (msg.value >= coste, "Compra menos Tokens o paga con mas ethers.");
        //Diferencia de lo que el cliente paga
        uint returnValue = msg.value - coste;
        // Disney retorna la cantidad de ethers al cliente
        msg.sender.transfer(returnValue);
        // Obtención del número de tokens disponibles
        uint Balance = balanceOf();
        require(_numTokens <= Balance, "Compra un numero menor de tokens");
        // Se transfiere el número de tokens al cliente
        token.transfer(msg.sender, _numTokens);
        // Registro de tokens comprados
        Clientes[msg.sender].tokens_comprados += _numTokens;
    }

    // Balance de tokens del contrato disney
    function balanceOf() public view returns(uint){
        return token.balanceOf(address(this));
    }

    // Visualizar el número de tokens restantes de un cliente
    function MisTokens() public view returns (uint){
        return token.balanceOf(msg.sender);
    }

    // Función para generar mas tokens
    function GeneraTokens(uint _numTokens) public Unicamente(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }

    //Modificador para controlar las funiones ejecutables por disney
    modifier Unicamente(address _direccion) {
        require(_direccion == owner, "No tienes permisos para ejecutar esta función.");
        _;
    }

    // ------------------------------------- GESTION DE TOKENS ------------------------------------- 

    // Eventos
    event disfruta_atraccion(string, uint, address);
    event nueva_atraccion(string, uint);
    event baja_atraccion(string);

    // Estructura de la atraccion
    struct atraccion {
        string nombre_atraccion;
        uint precio_atraccion;
        bool estado_atraccion;
    }

    // Mapping para reclacion de un nombre e una atraccion con una estructura de datos de la atraccion
    mapping (string => atraccion) public MappingAtracciones;

    // Array para almacenar el nombre de las atracciones
    string [] Atracciones;

    // Mapping para relacionar una identidad (cliente) con su historial en DISNEY
    mapping (address => string []) HistorialAtracciones;

    // Crear nuevas atracciones para DISNEY (SOLO es ejecutable por Disney)
    function NuevaAtraccion(string memory _nombreAtraccion, uint _precio) public Unicamente(msg.sender){
        // Creación de una atracción en Disney
        MappingAtracciones[_nombreAtraccion] = atraccion(_nombreAtraccion, _precio, true);
        // Almacenamiento en un array el nombre de la atraccion
        Atracciones.push(_nombreAtraccion);
        // Emision del evento para la nueva atraccion
        emit nueva_atraccion(_nombreAtraccion, _precio);
    }

    // Dar de baja a las atracciones en Disney
    function BajaAtraccion (string memory _nombreAtraccion) public Unicamente(msg.sender) {
        // El estado de la atraccion pasa a FALSE => No esta en uso
        MappingAtracciones[_nombreAtraccion].estado_atraccion = false;
        // Emision del evento para la baja de la atraccion
        emit baja_atraccion(_nombreAtraccion);
    }

    // Visualizar las atracciones de Disney
    function AtraccionesDisponibles() public view returns (string [] memory){
        return Atracciones;
    }

    // Funcion para subirse a una atracción de disney y pagar en tokens
    function SubirseAtraccion (string memory _nombreAtraccion) public {
        // Precio de la atraccion (en tokens)
        uint tokens_atraccion = MappingAtracciones[_nombreAtraccion].precio_atraccion;
        // Verifica el estado de la atraccion (si esta disponible para su uso)
        require(MappingAtracciones[_nombreAtraccion].estado_atraccion == true, "La atraccion no esta disponible en estos momentos.");
        // Verifica el numero de tokens que tiene el cliente para subirse a la atraccion
        require(tokens_atraccion <= MisTokens(), "Necesitas mas Tokens para subirte a esta atraccion.");
        /* El Cliente paga atraccion con Tokens:
        - Ha sido necesario crear una funcion en ERC20.sol con el nombre de: 'transferencia_disney'
        debido a que en caso de usar el transfer o TransferFrom las direcciones que se escogian
        para realiazar las transaccion eran equivocadas. Ya que el msg.sender que recibia el metodo
        Transfer o TransferFrom era la direccion del contrato.
        */
        token.transferencia_disney(msg.sender, address(this), tokens_atraccion);
        // Almacenamiento en el historial de atracciones del cliente
        HistorialAtracciones[msg.sender].push(_nombreAtraccion);
        // Emision del evento para disfrutar de la atraccion
        emit disfruta_atraccion(_nombreAtraccion, tokens_atraccion, msg.sender);
    }

    // Visualiza el historial completo de atracciones disfrutadas por un cliente
    function Historial() public view returns (string [] memory){
        return HistorialAtracciones[msg.sender];
    }

    // Funcion para que un cliente de Disney pueda devolver Tokens
    function DevolverTokens (uint _numTokens) public payable {
        // El número de tokens a devolver es positivo
        require(_numTokens > 0, "Necesitas devolver una cantidad positiva de tokens.");
        // El usuario debe tener el número de tokens que desea devolver
        require(_numTokens <= MisTokens(), "No tienes los tokens que deseas devolver.");
        // El cliente devuleve los tokens
        token.transferencia_disney(msg.sender, address(this), _numTokens);
        // Devolucion de los ethers al cliente
        msg.sender.transfer(PrecioTokens(_numTokens));
    }
}