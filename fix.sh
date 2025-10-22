curl -L https://app.drosera.io/install | bash
curl -L https://foundry.paradigm.xyz | bash
curl -fsSL https://bun.sh/install | bash
source /root/.bashrc
droseraup
foundryup
mkdir my-drosera-trap
cd my-drosera-trap
forge init -t drosera-network/trap-foundry-template
forge install drosera-network/contracts

cat > remappings.txt << 'EOF'
forge-std/=node_modules/forge-std/src/
drosera-contracts/=lib/contracts/src/
EOF

bun install
forge build

# Запрос данных у пользователя
echo ""
echo "=== Настройка Drosera Trap ==="
echo ""
read -p "Введите адрес Trap: " TRAP_ADDRESS
read -p "Введите адрес кошелька оператора: " OPERATOR_ADDRESS
read -p "Введите приватный ключ кошелька оператора: " OPERATOR_PRIVATE_KEY

echo ""
echo "Обновление drosera.toml..."

# Замена response_contract на новый адрес
sed -i 's/0x183D78491555cb69B68d2354F7373cc2632508C7/0x25E2CeF36020A736CF8a4D2cAdD2EBE3940F4608/g' drosera.toml

# Замена whitelist = [] на whitelist = ["адрес оператора"]
sed -i "s/whitelist = \[\]/whitelist = [\"$OPERATOR_ADDRESS\"]/g" drosera.toml

# Добавление строки address = "адрес trap" после первой строки whitelist
sed -i "0,/whitelist = /s/whitelist = .*/&\naddress = \"$TRAP_ADDRESS\"/" drosera.toml

echo "Конфигурация обновлена!"
echo ""
echo "Применение конфигурации Drosera..."
drosera apply --private-key "$OPERATOR_PRIVATE_KEY"

echo ""
echo "=== Готово! ==="
