# Установка зависимостей и инструментов
curl -L https://app.drosera.io/install | bash
curl -L https://foundry.paradigm.xyz | bash
curl -fsSL https://bun.sh/install | bash
source /root/.bashrc
droseraup
foundryup

# Инициализация директории trap
mkdir -p my-drosera-trap
cd my-drosera-trap
forge init -t drosera-network/trap-foundry-template
forge install drosera-network/contracts

cat > remappings.txt << 'EOF'
forge-std/=node_modules/forge-std/src/
drosera-contracts/=lib/contracts/src/
EOF

bun install
forge build

echo
echo "=== Настройка Drosera Trap ==="
echo
read -rp "Введите адрес Trap: " TRAP_ADDRESS
read -rp "Введите адрес кошелька оператора: " OPERATOR_ADDRESS
read -rp "Введите приватный ключ кошелька оператора: " OPERATOR_PRIVATE_KEY

echo
echo "Обновление drosera.toml..."

# Подмена response_contract (адрес можно вынести отдельной переменной, если нужно спрашивать)
sed -i 's/0x183D78491555cb69B68d2354F7373cc2632508C7/0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608/g' drosera.toml

# Подмена whitelist на значения пользователя
sed -i "s|whitelist = .*|whitelist = [\"$OPERATOR_ADDRESS\"]|" drosera.toml

# Добавляем/заменяем строку address после whitelist. Удаляем возможную старую строку address:
sed -i "0,/whitelist = /s/whitelist = .*/&\naddress = \"$TRAP_ADDRESS\"/" drosera.toml

echo "Конфигурация обновлена!"
echo
echo "Применение конфигурации Drosera..."
drosera apply --private-key "$OPERATOR_PRIVATE_KEY"
echo
echo "=== Готово! ==="
