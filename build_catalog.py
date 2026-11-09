import json
from pathlib import Path
p=Path(__file__).parent
# Original side-profile illustrations; no game assets are extracted.
rows=[
('Aston Martin DB9','gt','#a4b1ba'),('Audi A3 3.2 quattro','hatch','#ca4939'),('Audi A4 3.2 FSI quattro','sedan','#89969d'),('Audi TT 3.2 quattro','round','#d0d4d6'),('Cadillac CTS','sedan','#44464c'),('Chevrolet Cobalt SS','coupe','#e6bd39'),('Chevrolet Corvette C6','super','#e8c23b'),('Dodge Viper SRT10','long','#cc3434'),('Fiat Punto','hatch','#3e73bc'),('Ford GT','super','#72b7d5'),('Ford Mustang GT','muscle','#bf3839'),('Lamborghini Gallardo','wedge','#e5c634'),('Lamborghini Murciélago','wedge','#ef9d31'),('Lexus IS 300','sedan','#a4adb7'),('Lotus Elise','small','#419b65'),('Mazda RX-7','coupe','#e5b936'),('Mazda RX-8','round','#b63438'),('Mercedes-Benz CLK 500','gt','#8e9aab'),('Mercedes-Benz SL 500','long','#d1d5da'),('Mercedes-Benz SLR McLaren','long','#b6c1c9'),('Mitsubishi Eclipse GT','round','#df7d31'),('Mitsubishi Lancer Evolution VIII','rally','#cf3b36'),('Pontiac GTO','muscle','#315b93'),('Porsche 911 Carrera S','porsche','#bdc6ce'),('Porsche 911 GT2','porsche','#e9ca45'),('Porsche 911 Turbo S','porsche','#536578'),('Porsche Carrera GT','super','#b8c2c8'),('Porsche Cayman S','porsche','#d0d6d8'),('Renault Clio V6','hatch','#467dbc'),('Subaru Impreza WRX STI','rally','#285cb7'),('Toyota Supra','coupe','#df4231'),('Vauxhall Monaro VXR','muscle','#c8403b')]
cars=[]
for name,shape,color in rows:
    cars.append(dict(name=name,shape=shape,color=color,group='career',stripe='',wing=shape in ['rally']))
for name,shape,color,stripe,wing in [('BMW M3 GTR','coupe','#d5d9dd','#285ba8',True),('BMW M3 GTR Street','coupe','#bbc4cb','',False),('Chevrolet Camaro SS 1967','classic','#35373c','#eeeeee',False),('Chevrolet Corvette C6.R','super','#e2be2b','#25262c',True),('Mercedes-Benz SL 65 AMG','long','#818b96','',False)]:
    cars.append(dict(name=name,shape=shape,color=color,stripe=stripe,wing=wing,group='bonus'))
blacklist=[(15,'Sonny','Volkswagen Golf GTI','hatch','#24262c','#de393a'),(14,'Taz','Lexus IS 300','sedan','#d2bc42','#303033'),(13,'Vic','Toyota Supra','coupe','#434051','#edb43b'),(12,'Izzy','Mazda RX-8','round','#c0c3ca','#c52b35'),(11,'Big Lou','Mitsubishi Eclipse GT','round','#296eaa','#d2d3d6'),(10,'Baron','Porsche Cayman S','porsche','#302f35','#ca3b3f'),(9,'Earl','Mitsubishi Lancer Evolution VIII','rally','#e0e1d5','#c65324'),(8,'Jewels','Ford Mustang GT','muscle','#c7c3bb','#c84433'),(7,'Kaze','Mercedes-Benz CLK 500','gt','#d6c8a8','#d74965'),(6,'Ming','Lamborghini Gallardo','wedge','#dfbb30','#25262c'),(5,'Webster','Chevrolet Corvette C6','super','#a5afaf','#218a99'),(4,'JV','Dodge Viper SRT10','long','#91b844','#292a2a'),(3,'Ronnie','Aston Martin DB9','gt','#d0b951','#395b31'),(2,'Bull','Mercedes-Benz SLR McLaren','long','#24282d',''),(1,'Razor','BMW M3 GTR','coupe','#d5d9dd','#285ba8')]
# Golf GTI is a career car as well as Sonny's variant.
cars.insert(32,dict(name='Volkswagen Golf GTI',shape='hatch',color='#b73b39',group='career',stripe='',wing=False))
for rank,driver,name,shape,color,stripe in blacklist:
    cars.append(dict(name=name,shape=shape,color=color,stripe=stripe,wing=True,group='blacklist',driver=driver,rank=rank))
(p/'Cars.js').write_text('.pragma library\nvar cars = '+json.dumps(cars,ensure_ascii=False,indent=2)+';\n')
(p/'catalog.json').write_text(json.dumps(cars,ensure_ascii=False,indent=2)+'\n')
print(f'{len(cars)} entries; {len(rows)+1} career models; 5 bonus models; 15 Blacklist variants')
for c in cars:
    if c['name'] in ['Mercedes-Benz SL 500','Porsche 911 GT2'] and c['group']=='career': c['group']='bonus'
for name in ['Chevrolet Corvette C6','Chevrolet Corvette C6.R','Lotus Elise','Mercedes-Benz SL 500','Mercedes-Benz SL 65 AMG','Porsche 911 Carrera S','Porsche 911 GT2','Toyota Supra']:
    original=next(c for c in cars if c['name']==name)
    cars.append(dict(original, name=name+' · Black Edition', group='bonus',stripe='#23272e',wing=True))
cars.append(dict(name='Ford GT · Castrol Syntec',shape='super',color='#f1f0e7',stripe='#278b42',wing=False,group='bonus'))
(p/'Cars.js').write_text('.pragma library\nvar cars = '+json.dumps(cars,ensure_ascii=False,indent=2)+';\n')
(p/'catalog.json').write_text(json.dumps(cars,ensure_ascii=False,indent=2)+'\n')
print(f'Final catalog: {len(cars)} entries')
