import { Router } from 'express';
import { pool } from '../db/pool.js';
import { getCompanyId } from '../services/config.js';

export const replacementGroupsAdminRouter = Router();

// Configuration First (п.12 ТЗ) — /internal/replacement-groups. Доступ уже
// закрыт Basic Auth на уровне Next.js middleware. Чисто управление
// данными — сама Replacement Matrix (граф замены) ещё не закодирована
// (CLAUDE.md §3.1), здесь только справочник групп + членство семейств.

// GET /api/replacement-groups — группы + все families с их текущей группой.
replacementGroupsAdminRouter.get('/replacement-groups', async (req, res, next) => {
    try {
        const companyId = await getCompanyId();
        const { rows: groups } = await pool.query('SELECT id, code, name FROM replacement_groups ORDER BY code');
        const { rows: families } = await pool.query(
            `SELECT id, code, brand, model_name, replacement_group_id
             FROM product_families WHERE company_id = $1 AND is_active = TRUE
             ORDER BY brand, model_name`,
            [companyId]
        );
        res.json({ data: { groups, families } });
    } catch (err) { next(err); }
});

function badReq(message) {
    const e = new Error(message);
    e.status = 400;
    return e;
}

function validateGroupBody(body) {
    const { code, name } = body ?? {};
    if (typeof code !== 'string' || !/^[a-z0-9_]+$/.test(code)) {
        throw badReq('code must be snake_case (lowercase letters, digits, underscores)');
    }
    if (typeof name !== 'string' || !name.trim()) throw badReq('name is required');
    return { code, name: name.trim() };
}

function isUniqueViolation(err) {
    return err.code === '23505';
}
function isFkViolation(err) {
    return err.code === '23503';
}

// POST /api/replacement-groups — новая группа.
replacementGroupsAdminRouter.post('/replacement-groups', async (req, res, next) => {
    try {
        const v = validateGroupBody(req.body);
        const { rows } = await pool.query(
            'INSERT INTO replacement_groups (code, name) VALUES ($1, $2) RETURNING id, code, name',
            [v.code, v.name]
        );
        res.status(201).json({ data: rows[0] });
    } catch (err) {
        if (isUniqueViolation(err)) err.status = 409;
        next(err);
    }
});

// PUT /api/replacement-groups/:id — переименовать группу.
replacementGroupsAdminRouter.put('/replacement-groups/:id', async (req, res, next) => {
    try {
        const v = validateGroupBody(req.body);
        const { rows } = await pool.query(
            'UPDATE replacement_groups SET code = $1, name = $2 WHERE id = $3 RETURNING id, code, name',
            [v.code, v.name, req.params.id]
        );
        if (rows.length === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.json({ data: rows[0] });
    } catch (err) {
        if (isUniqueViolation(err)) err.status = 409;
        next(err);
    }
});

// DELETE /api/replacement-groups/:id — блокируется FK (product_families
// ещё ссылается на группу) → 409, а не голый 500.
replacementGroupsAdminRouter.delete('/replacement-groups/:id', async (req, res, next) => {
    try {
        const { rowCount } = await pool.query('DELETE FROM replacement_groups WHERE id = $1', [req.params.id]);
        if (rowCount === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.status(204).end();
    } catch (err) {
        if (isFkViolation(err)) {
            err.status = 409;
            err.message = 'Группа ещё используется — сначала переназначьте или уберите модели из неё';
        }
        next(err);
    }
});

// PUT /api/product-families/:id/replacement-group — назначить/снять группу
// у одной модели. Тело: { replacement_group_id: <id> | null }.
replacementGroupsAdminRouter.put('/product-families/:id/replacement-group', async (req, res, next) => {
    try {
        const raw = req.body?.replacement_group_id;
        const groupId = raw === null || raw === undefined || raw === '' ? null : Number(raw);
        if (groupId !== null && !Number.isInteger(groupId)) throw badReq('replacement_group_id must be an integer or null');
        const { rows } = await pool.query(
            `UPDATE product_families SET replacement_group_id = $1
             WHERE id = $2 RETURNING id, code, replacement_group_id`,
            [groupId, req.params.id]
        );
        if (rows.length === 0) { const e = new Error('not_found'); e.status = 404; throw e; }
        res.json({ data: rows[0] });
    } catch (err) { next(err); }
});
