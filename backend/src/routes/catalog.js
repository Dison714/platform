import { Router } from 'express';
import { listProducts, getProduct, listFamilies, listCategories } from '../services/catalog.js';

export const catalogRouter = Router();

// Язык берётся из ?lang= (default en, fallback на en при незаполненном
// переводе — внутри сервиса). Пагинации нет (продуктов 41), но ответы
// обёрнуты в { data, meta } — пагинацию можно добавить в meta без ломки клиента.

catalogRouter.get('/products', async (req, res, next) => {
    try {
        const result = await listProducts({
            lang: req.query.lang,
            category: req.query.category,
            model: req.query.model,
            available: req.query.available === 'true',
        });
        res.json(result);
    } catch (err) {
        next(err);
    }
});

catalogRouter.get('/products/:idOrSlug', async (req, res, next) => {
    try {
        const result = await getProduct({ idOrSlug: req.params.idOrSlug, lang: req.query.lang });
        if (!result) return res.status(404).json({ error: 'product_not_found' });
        res.json(result);
    } catch (err) {
        next(err);
    }
});

catalogRouter.get('/families', async (req, res, next) => {
    try {
        const result = await listFamilies({ lang: req.query.lang });
        res.json(result);
    } catch (err) {
        next(err);
    }
});

catalogRouter.get('/categories', async (req, res, next) => {
    try {
        const result = await listCategories({ lang: req.query.lang });
        res.json(result);
    } catch (err) {
        next(err);
    }
});
