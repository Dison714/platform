import { findProduct, computeBaseRental } from './pricing.js';
import { computeDeliveryFee } from './delivery.js';
import { computeInsurance } from './insurance.js';
import { computeEquipment } from './equipment.js';
import { computeDeposit } from './deposit.js';
import { displayName } from './catalog.js';

const CURRENCY = 'IDR';

// Полный расчёт аренды: база + доставка + страховка + оборудование = ИТОГО К
// ОПЛАТЕ; депозит — ОТДЕЛЬНО (возвращаемый, не в итоге). Прозрачная разбивка.
export async function buildQuote({ product, rentalDays, insurance, equipment, lang = 'en', startDate = null }) {
    if (!product) { const e = new Error('product is required'); e.status = 400; throw e; }
    if (!Number.isInteger(rentalDays) || rentalDays < 1) {
        const e = new Error('rental_days must be a positive integer');
        e.status = 400;
        throw e;
    }

    const prod = await findProduct(product);
    if (!prod) { const e = new Error('product_not_found'); e.status = 404; throw e; }

    const baseRental = await computeBaseRental(prod.id, rentalDays, startDate);
    const delivery = await computeDeliveryFee({ rentalDays });
    const insuranceResult = await computeInsurance(insurance, rentalDays);
    const equipmentResult = await computeEquipment(equipment, rentalDays, lang);
    const deposit = await computeDeposit(prod.family_id, rentalDays);

    const totalPayable =
        baseRental.price_idr +
        delivery.fee_idr +
        (insuranceResult?.total_idr ?? 0) +
        (equipmentResult?.total_idr ?? 0);

    return {
        product: {
            id: prod.id,
            slug: prod.slug,
            name: displayName(null, prod.brand, prod.model_name, prod.color_name, prod.variant),
        },
        rental_days: rentalDays,
        currency: CURRENCY,
        breakdown: {
            base_rental: baseRental,
            delivery,
            insurance: insuranceResult,
            equipment: equipmentResult,
        },
        total_payable_idr: totalPayable,
        deposit, // отдельно: возвращаемый залог, НЕ в total_payable_idr
    };
}
