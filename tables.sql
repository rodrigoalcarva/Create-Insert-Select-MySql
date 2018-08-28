Drop table  Dependente ;
Drop table  compra ;
Drop table  Consumidor ;
Drop table  composto ;
Drop table  Produto ;
Drop table  Marca ;
Drop table  Elemento ;

Create table  Consumidor  (
	numero	int(9),
	email	varchar(30)	not null,
	sexo	char(1)	not null,
	nascimento	date	not null,
	constraint Consumidor_sexo_RI001	 check (sexo in ('F','M')),
	constraint Consumidor_unique_RI002	unique(email),
	constraint pk_Consumidor	 primary key (numero)
);

Create table  Dependente  (
	consumidor	int(9),
	numero	int(2),
	sexo	char(1)	not null,
	nascimento	date	not null,
	constraint Dependente_sexo_RI003 check (sexo in ('F','M')),
	constraint fk_Dependente_consumidor	 foreign key (consumidor) references Consumidor(numero) on delete cascade,
	constraint pk_Dependente	 primary key (consumidor,numero)
);


Create table  Elemento  (
	codigo	char(3),
	nome	varchar(25) not null,
	pegadaEcologica	int(2) not null,
	saude	int(2) not null,
	constraint pk_Elemento	 primary key (codigo)
);

Create table  Marca  (
	numero	int(7),
	nome	varchar(30) not null,
	constraint pk_Marca	 primary key (numero)
);

Create table  Produto  (
	codigo	int(6),
	marca	int(7),
	nome	varchar(50) not null,
	tipo	char(10),
	comercioJusto	char(1),
	constraint Produto_tipo_RI004	check (tipo in ('alimentac','lar','jardim','automov','viagem','electrodom')),
	constraint Produto_comercioJusto_RI005	 check (comercioJusto in ('A','B','C','D')),
	constraint fk_Produto_marca	 foreign key (marca) references Marca(numero) on delete cascade,
	constraint pk_Produto	 primary key (codigo,marca)
);


Create table  compra  (
	produto	int(6),
	prodMarca	int(7),
	consumidor	int(9),
	quantidade	decimal(10,3)	not null,
	constraint compra_quantidade_RI006	check (quantidade>0),
	constraint fk_compra_produto	 foreign key (produto,prodMarca) references Produto(codigo,marca) on delete cascade,
	constraint fk_compra_consumidor	 foreign key (consumidor) references Consumidor(numero) on delete cascade,
	constraint pk_compra	 primary key (produto,prodMarca,consumidor)
);


Create table  composto  (
	produto	int(6),
	prodMarca	int(7),
	elemento	char(3),
	percentagem	decimal(4,1)	not null,
	constraint composto_percentagem_RI007	check (percentagem>0 and percentagem<=100),
	constraint fk_composto_produto	 foreign key (produto,prodMarca) references Produto(codigo,marca) on delete cascade,
	constraint fk_composto_elemento	 foreign key (elemento) references Elemento(codigo) on delete cascade,
	constraint pk_composto	 primary key (produto,prodMarca,elemento)
);
